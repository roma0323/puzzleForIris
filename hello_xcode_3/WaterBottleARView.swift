import SwiftUI
import ARKit
import RealityKit
import Vision

struct WaterBottleARView: View {
    @StateObject private var arViewModel = ARViewModel()
    
    var body: some View {
        ZStack {
            ARViewContainer(arViewModel: arViewModel)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Spacer()
                Text(arViewModel.detectionMessage)
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
    @Published var detectionMessage: String = "Looking for bottle..."
    private var detectionRequest: VNRequest?
    weak var arView: ARView?
    private var currentAnchor: AnchorEntity?
    
    init() {
        setupVision()
    }
    
    private func setupVision() {
        setupBasicObjectDetection()
    }
    
    private func setupBasicObjectDetection() {
        let request = VNDetectRectanglesRequest { [weak self] request, error in
            self?.processRectangles(for: request, error: error)
        }
        request.minimumAspectRatio = 0.3
        request.maximumAspectRatio = 1.0
        self.detectionRequest = request
    }
    
    private func processRectangles(for request: VNRequest, error: Error?) {
        DispatchQueue.main.async {
            guard let results = request.results as? [VNRectangleObservation],
                  !results.isEmpty else {
                self.detectionMessage = "Looking for bottle..."
                return
            }
            
            // When a rectangle is detected that could be a bottle
            let observation = results[0]
            let confidence = Int(observation.confidence * 100)
            self.detectionMessage = "Possible bottle detected! (\(confidence)% confident)"
            
            // Convert normalized coordinates to view coordinates
            if let arView = self.arView {
                let viewWidth = arView.frame.width
                let viewHeight = arView.frame.height
                
                // Get center point of the detected rectangle
                let centerX = observation.boundingBox.midX * viewWidth
                let centerY = (1 - observation.boundingBox.midY) * viewHeight
                let screenPoint = CGPoint(x: centerX, y: centerY)
                
                // Perform hit test with detected point
                let results = arView.hitTest(screenPoint, types: [.existingPlaneUsingExtent, .estimatedHorizontalPlane])
                
                if let firstResult = results.first {
                    // Create or update text at the hit test position
                    self.addOrUpdateText(at: firstResult.worldTransform, text: "Bottle", confidence: confidence)
                }
            }
        }
    }
    
    private func addOrUpdateText(at transform: simd_float4x4, text: String, confidence: Int) {
        guard let arView = arView else { return }
        
        // Remove existing anchor if any
        if let currentAnchor = currentAnchor {
            arView.scene.removeAnchor(currentAnchor)
        }
        
        // Create text mesh
        let textMesh = MeshResource.generateText(
            "\(text) (\(confidence)%)",
            extrusionDepth: 0.01,
            font: .systemFont(ofSize: 0.1),
            containerFrame: .zero,
            alignment: .center,
            lineBreakMode: .byTruncatingTail
        )
        
        // Create material
        var material = SimpleMaterial()
        material.baseColor = MaterialColorParameter.color(.white)
        
        // Create text entity
        let textEntity = ModelEntity(mesh: textMesh, materials: [material])
        
        // Create anchor and position text above the detected point
        let anchor = AnchorEntity(world: transform)
        textEntity.position.y += 0.1 // Raise text 10cm above the anchor
        anchor.addChild(textEntity)
        
        // Add to scene and store reference
        arView.scene.addAnchor(anchor)
        currentAnchor = anchor
    }
    
    func processFrame(_ pixelBuffer: CVPixelBuffer) {
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .up)
        guard let request = detectionRequest else { return }
        try? imageRequestHandler.perform([request])
    }
}

struct ARViewContainer: UIViewRepresentable {
    let arViewModel: ARViewModel
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        
        // Configure AR session
        let session = arView.session
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal, .vertical]
        session.run(config)
        
        // Add coaching overlay
        let coachingOverlay = ARCoachingOverlayView()
        coachingOverlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        coachingOverlay.session = session
        coachingOverlay.goal = .horizontalPlane
        arView.addSubview(coachingOverlay)
        
        // Set up session delegate
        session.delegate = context.coordinator
        
        // Store ARView reference in view model
        arViewModel.arView = arView
        
        context.coordinator.arView = arView
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, ARSessionDelegate {
        let parent: ARViewContainer
        weak var arView: ARView?
        
        init(_ parent: ARViewContainer) {
            self.parent = parent
            super.init()
        }
        
        func session(_ session: ARSession, didUpdate frame: ARFrame) {
            parent.arViewModel.processFrame(frame.capturedImage)
        }
    }
}

#Preview {
    WaterBottleARView()
} 