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
    @State private var timeRemaining: Int = 5
    @State private var timer: Timer?
    @State private var isSuccess = false
    @State private var showError = false
    
    private let requiredVolume: Float = -20.0 // Adjust this value based on testing
    private let requiredDuration: Int = 1 // seconds
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Volume Level Challenge")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Yell for \(timeRemaining) seconds!")
                .font(.headline)
            
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
            
            Text(String(format: "Current Volume: %.1f dB", audioManager.currentVolume))
                .font(.subheadline)
            
            if isSuccess {
                Text("Success! You've completed the volume challenge!")
                    .foregroundColor(.green)
                    .padding()
            } else if showError {
                Text("Try again! Keep the volume up!")
                    .foregroundColor(.red)
                    .padding()
            }
            
            Button(action: startChallenge) {
                Text(audioManager.isRecording ? "Stop" : "Start Challenge")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(audioManager.isRecording ? Color.red : Color.blue)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
        }
        .padding()
        .onDisappear {
            audioManager.stopRecording()
            timer?.invalidate()
        }
    }
    
    private var volumeColor: Color {
        if audioManager.currentVolume >= requiredVolume {
            return .green
        } else {
            return .red
        }
    }
    
    private func startChallenge() {
        if audioManager.isRecording {
            audioManager.stopRecording()
            timer?.invalidate()
            return
        }
        
        isSuccess = false
        showError = false
        timeRemaining = requiredDuration
        audioManager.startRecording()
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
                if audioManager.currentVolume < requiredVolume {
                    showError = true
                    audioManager.stopRecording()
                    timer?.invalidate()
                }
            } else {
                if audioManager.currentVolume >= requiredVolume {
                    isSuccess = true
                } else {
                    showError = true
                }
                audioManager.stopRecording()
                timer?.invalidate()
            }
        }
    }
}

#Preview {
    VolumeLevelView()
} 
