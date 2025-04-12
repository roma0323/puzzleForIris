import SwiftUI
import ARKit
import RealityKit

struct WaterBottleARView: View {
    @StateObject private var arViewModel = ARViewModel()
    
    var body: some View {
        ZStack {
            ARViewContainer(arViewModel: arViewModel)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Spacer()
                Text(arViewModel.statusMessage)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(10)
                    .padding(.bottom, 50)
            }
        }
    }
}

class ARViewModel: ObservableObject {
    @Published var statusMessage: String = "Tap anywhere to place 3D text"
    weak var arView: ARView?
    private var textEntities: [AnchorEntity] = []
    
    func addText(at location: SIMD3<Float>, text: String = "Hello AR!") {
        guard let arView = arView else { return }
        
        // Create text mesh with improved appearance
        let textMesh = MeshResource.generateText(
            text,
            extrusionDepth: 0.02,
            font: .boldSystemFont(ofSize: 0.15),
            containerFrame: .zero,
            alignment: .center,
            lineBreakMode: .byTruncatingTail
        )
        
        // Create material with modern appearance
        var material = SimpleMaterial()
        material.baseColor = MaterialColorParameter.color(.white)
        material.metallic = MaterialScalarParameter(floatLiteral: 0.8)
        material.roughness = MaterialScalarParameter(floatLiteral: 0.2)
        
        // Create text entity
        let textEntity = ModelEntity(mesh: textMesh, materials: [material])
        
        // Configure physics to make text static
        textEntity.collision = CollisionComponent(shapes: [.generateBox(size: textMesh.bounds.extents)])
        textEntity.physicsBody = PhysicsBodyComponent(
            massProperties: .init(mass: 0.0),  // Zero mass makes it static
            material: .default,
            mode: .static  // Static mode prevents any movement
        )
        
        // Create anchor and position text
        let anchor = AnchorEntity(world: .init(location))
        textEntity.position.y += 0.1 // Raise text 10cm above the anchor
        anchor.addChild(textEntity)
        
        // Add shadow plane
        let shadowPlane = ModelEntity(
            mesh: .generatePlane(width: Float(textMesh.bounds.max.x - textMesh.bounds.min.x) + 0.05,
                               depth: Float(textMesh.bounds.max.z - textMesh.bounds.min.z) + 0.05),
            materials: [SimpleMaterial(color: .black.withAlphaComponent(0.3), isMetallic: false)]
        )
        shadowPlane.position.y -= 0.001
        anchor.addChild(shadowPlane)
        
        // Add to scene and store reference
        arView.scene.addAnchor(anchor)
        textEntities.append(anchor)
        
        // Update status message
        statusMessage = "Text placed! Tap anywhere to add more"
    }
    
    func handleTap(at point: CGPoint) {
        guard let arView = arView else { return }
        
        let results = arView.raycast(from: point, allowing: .estimatedPlane, alignment: .any)
        
        if let firstResult = results.first {
            let worldPosition = firstResult.worldTransform.columns.3
            addText(at: SIMD3(worldPosition.x, worldPosition.y, worldPosition.z))
        }
    }
}

struct ARViewContainer: UIViewRepresentable {
    let arViewModel: ARViewModel
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        
        // Configure AR session
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal, .vertical]
        arView.session.run(config)
        
        // Add coaching overlay
        let coachingOverlay = ARCoachingOverlayView()
        coachingOverlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        coachingOverlay.session = arView.session
        coachingOverlay.goal = .horizontalPlane
        arView.addSubview(coachingOverlay)
        
        // Add tap gesture
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
        arView.addGestureRecognizer(tapGesture)
        
        // Store ARView reference in view model
        arViewModel.arView = arView
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject {
        let parent: ARViewContainer
        
        init(_ parent: ARViewContainer) {
            self.parent = parent
        }
        
        @objc func handleTap(_ gesture: UITapGestureRecognizer) {
            let location = gesture.location(in: gesture.view)
            parent.arViewModel.handleTap(at: location)
        }
    }
}

#Preview {
    WaterBottleARView()
} 