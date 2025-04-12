import SwiftUI
import CoreNFC

class NFCSessionManager: NSObject, ObservableObject, NFCNDEFReaderSessionDelegate {
    @Published var nfcText = ""
    @Published var isScanning = false
    var nfcSession: NFCNDEFReaderSession?
    
    func startScanning() {
        guard NFCNDEFReaderSession.readingAvailable else {
            print("NFC not available on this device")
            return
        }
        
        nfcSession = NFCNDEFReaderSession(delegate: self,
                                         queue: DispatchQueue.main,
                                         invalidateAfterFirstRead: true)
        nfcSession?.begin()
        isScanning = true
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        print("NFC session invalidated with error: \(error.localizedDescription)")
        isScanning = false
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        guard let ndefMessage = messages.first,
              let record = ndefMessage.records.first,
              let text = String(data: record.payload, encoding: .utf8) else {
            return
        }
        
        DispatchQueue.main.async {
            self.nfcText = text
            self.isScanning = false
        }
    }
}

struct NFCReader: View {
    @StateObject private var nfcManager = NFCSessionManager()
    
    var body: some View {
        VStack(spacing: 20) {
            Text("NFC Tag Reader")
                .font(.title)
                .padding()
            
            if nfcManager.isScanning {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                Text("Scanning for NFC tags...")
                    .foregroundColor(.gray)
            } else {
                if !nfcManager.nfcText.isEmpty {
                    Text("Tag Content:")
                        .font(.headline)
                    Text(nfcManager.nfcText)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.gray.opacity(0.1))
                        )
                }
                
                Button(action: {
                    nfcManager.startScanning()
                }) {
                    HStack {
                        Image(systemName: "radiowaves.left")
                        Text("Scan NFC Tag")
                    }
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
                }
            }
        }
        .padding()
    }
}

#Preview {
    NFCReader()
} 