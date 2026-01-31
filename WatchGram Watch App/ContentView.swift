import SwiftUI
import AVFoundation
import Speech

struct ContentView: View {
    @StateObject private var viewModel = ChatViewModel()
    @State private var isRecording = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                // Messages list
                if viewModel.messages.isEmpty {
                    Spacer()
                    VStack(spacing: 8) {
                        Image(systemName: "message.circle.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.blue)
                        Text("Tap to speak")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                } else {
                    ScrollViewReader { proxy in
                        ScrollView {
                            LazyVStack(spacing: 8) {
                                ForEach(viewModel.messages) { message in
                                    MessageBubble(message: message)
                                        .id(message.id)
                                }
                            }
                            .padding(.horizontal, 4)
                        }
                        .onChange(of: viewModel.messages.count) { _ in
                            if let lastMessage = viewModel.messages.last {
                                withAnimation {
                                    proxy.scrollTo(lastMessage.id, anchor: .bottom)
                                }
                            }
                        }
                    }
                }
                
                // Record button
                Button(action: {
                    if isRecording {
                        viewModel.stopRecording()
                    } else {
                        viewModel.startRecording()
                    }
                    isRecording.toggle()
                }) {
                    ZStack {
                        Circle()
                            .fill(isRecording ? Color.red : Color.blue)
                            .frame(width: 60, height: 60)
                        
                        Image(systemName: isRecording ? "stop.fill" : "mic.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                }
                .buttonStyle(.plain)
                .scaleEffect(isRecording ? 1.1 : 1.0)
                .animation(.easeInOut(duration: 0.2), value: isRecording)
            }
            .navigationTitle("WatchGram")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            viewModel.requestPermissions()
        }
    }
}

struct MessageBubble: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.isFromUser {
                Spacer()
            }
            
            Text(message.text)
                .font(.caption)
                .padding(8)
                .background(message.isFromUser ? Color.blue : Color.gray.opacity(0.3))
                .foregroundColor(message.isFromUser ? .white : .primary)
                .cornerRadius(12)
            
            if !message.isFromUser {
                Spacer()
            }
        }
    }
}

struct ChatMessage: Identifiable {
    let id = UUID()
    let text: String
    let isFromUser: Bool
    let timestamp: Date
}

class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var isLoading = false
    
    private var speechRecognizer: SFSpeechRecognizer?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var audioEngine = AVAudioEngine()
    private let synthesizer = AVSpeechSynthesizer()
    
    // Telegram Bot Configuration
    private var botToken: String {
        UserDefaults.standard.string(forKey: "telegramBotToken") ?? ""
    }
    private var chatId: String {
        UserDefaults.standard.string(forKey: "telegramChatId") ?? ""
    }
    
    init() {
        speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-GB"))
    }
    
    func requestPermissions() {
        SFSpeechRecognizer.requestAuthorization { status in
            // Handle authorization
        }
    }
    
    func startRecording() {
        // Cancel any existing task
        recognitionTask?.cancel()
        recognitionTask = nil
        
        // Configure audio session
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("Audio session error: \(error)")
            return
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        let inputNode = audioEngine.inputNode
        guard let recognitionRequest = recognitionRequest else { return }
        
        recognitionRequest.shouldReportPartialResults = true
        
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            if let result = result {
                let transcription = result.bestTranscription.formattedString
                
                if result.isFinal {
                    self?.sendMessage(transcription)
                }
            }
        }
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            recognitionRequest.append(buffer)
        }
        
        audioEngine.prepare()
        
        do {
            try audioEngine.start()
        } catch {
            print("Audio engine error: \(error)")
        }
    }
    
    func stopRecording() {
        audioEngine.stop()
        recognitionRequest?.endAudio()
        audioEngine.inputNode.removeTap(onBus: 0)
    }
    
    func sendMessage(_ text: String) {
        guard !text.isEmpty else { return }
        
        // Add user message
        let userMessage = ChatMessage(text: text, isFromUser: true, timestamp: Date())
        DispatchQueue.main.async {
            self.messages.append(userMessage)
        }
        
        // Send to Telegram
        sendToTelegram(text)
    }
    
    private func sendToTelegram(_ text: String) {
        guard !botToken.isEmpty, !chatId.isEmpty else {
            // Show setup required message
            let errorMessage = ChatMessage(
                text: "Please set up your Telegram bot in Settings",
                isFromUser: false,
                timestamp: Date()
            )
            DispatchQueue.main.async {
                self.messages.append(errorMessage)
            }
            return
        }
        
        let urlString = "https://api.telegram.org/bot\(botToken)/sendMessage"
        guard let url = URL(string: urlString) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "chat_id": chatId,
            "text": text
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                print("Telegram error: \(error)")
                return
            }
            
            // Message sent successfully
            // In a real app, we'd set up webhooks or polling for responses
            DispatchQueue.main.async {
                let confirmMessage = ChatMessage(
                    text: "✓ Sent",
                    isFromUser: false,
                    timestamp: Date()
                )
                self?.messages.append(confirmMessage)
            }
        }.resume()
    }
    
    func speakResponse(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-GB")
        utterance.rate = 0.5
        synthesizer.speak(utterance)
    }
}

#Preview {
    ContentView()
}
