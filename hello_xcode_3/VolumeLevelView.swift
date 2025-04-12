import SwiftUI
import AVFoundation

class AudioManager: ObservableObject {
    private var audioRecorder: AVAudioRecorder?
    @Published var currentVolume: Float = 0.0
    @Published var isRecording = false
    
    init() {
        setupAudioRecorder()
    }
    
    private func setupAudioRecorder() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default)
            try audioSession.setActive(true)
            
            let settings: [String: Any] = [
                AVFormatIDKey: Int(kAudioFormatAppleLossless),
                AVSampleRateKey: 44100.0,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]
            
            audioRecorder = try AVAudioRecorder(url: URL(fileURLWithPath: "/dev/null"), settings: settings)
            audioRecorder?.isMeteringEnabled = true
            audioRecorder?.prepareToRecord()
        } catch {
            print("Audio session setup failed: \(error)")
        }
    }
    
    func startRecording() {
        audioRecorder?.record()
        isRecording = true
        startMonitoring()
    }
    
    func stopRecording() {
        audioRecorder?.stop()
        isRecording = false
    }
    
    private func startMonitoring() {
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self, self.isRecording else { return }
            self.audioRecorder?.updateMeters()
            self.currentVolume = self.audioRecorder?.averagePower(forChannel: 0) ?? 0.0
        }
    }
}

struct VolumeLevelView: View {
    @StateObject private var audioManager = AudioManager()
    @State private var elapsedTime: Double = 0
    @State private var timer: Timer?
    @State private var isSuccess = false
    var onSuccess: (() -> Void)?
    
    private let requiredVolume: Float = -30.0
    private let requiredDuration: Double = 1.0
    
    var body: some View {
        VStack(spacing: 30) {
          
            Spacer()
            
            // Time Progress Bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .frame(width: geometry.size.width, height: 10)
                        .opacity(0.3)
                        .foregroundColor(.gray)
                    
                    Rectangle()
                        .frame(width: min(CGFloat(elapsedTime / requiredDuration) * geometry.size.width, geometry.size.width), height: 10)
                        .foregroundColor(.blue)
                }
                .cornerRadius(5)
            }
            .frame(height: 10)
            .padding(.horizontal)
            
            // Volume meter
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .frame(width: geometry.size.width, height: 20)
                        .opacity(0.3)
                        .foregroundColor(.gray)
                    
                    Rectangle()
                        .frame(width: min(CGFloat(audioManager.currentVolume + 50) / 50 * geometry.size.width, geometry.size.width), height: 20)
                        .foregroundColor(volumeColor)
                }
                .cornerRadius(10)
            }
            .frame(height: 20)
            .padding(.horizontal)
            
        
            
            Spacer()
        }
        .padding()
        .onAppear {
            startChallenge()
        }
        .onDisappear {
            audioManager.stopRecording()
            timer?.invalidate()
        }
    }
    
    private var volumeColor: Color {
        if audioManager.currentVolume >= requiredVolume {
            return .green
        } else {
            return .orange
        }
    }
    
    private func startChallenge() {
        isSuccess = false
        elapsedTime = 0
        audioManager.startRecording()
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            if elapsedTime < requiredDuration {
                if audioManager.currentVolume >= requiredVolume {
                    elapsedTime += 0.1
                } else {
                    elapsedTime = 0
                }
            } else {
                isSuccess = true
                audioManager.stopRecording()
                timer?.invalidate()
                
                // Call the onSuccess callback when the challenge is completed
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    onSuccess?()
                }
            }
        }
    }
}

#Preview {
    VolumeLevelView()
} 
