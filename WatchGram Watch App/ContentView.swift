import SwiftUI
import AVFoundation
import WatchKit

// MARK: - Theme Colors (ClawBot style)
struct ClawTheme {
    static let background = Color(hex: "0A0A0F")
    static let surface = Color(hex: "1A1A24")
    static let primary = Color(hex: "8B5CF6")      // Purple
    static let secondary = Color(hex: "06B6D4")    // Cyan
    static let accent = Color(hex: "F472B6")       // Pink
    static let text = Color.white
    static let textSecondary = Color(hex: "9CA3AF")
    static let success = Color(hex: "10B981")
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Main Content View
struct ContentView: View {
    @StateObject private var viewModel = ChatViewModel()
    @State private var showOnboarding = !UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
    @State private var messageText = ""
    
    var body: some View {
        Group {
            if showOnboarding {
                OnboardingView(isPresented: $showOnboarding)
            } else {
                mainView
            }
        }
    }
    
    var mainView: some View {
        NavigationStack {
            ZStack {
                ClawTheme.background.ignoresSafeArea()
                
                VStack(spacing: 8) {
                    // Messages or welcome
                    if viewModel.messages.isEmpty {
                        welcomeView
                    } else {
                        messagesView
                    }
                    
                    // Voice input using TextField with dictation
                    voiceInputView
                }
            }
            .navigationTitle("ClawWatch")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink(destination: SettingsView()) {
                        Image(systemName: "gear")
                            .foregroundColor(ClawTheme.secondary)
                    }
                }
            }
        }
    }
    
    var welcomeView: some View {
        VStack(spacing: 12) {
            Spacer()
            
            // Claw icon
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [ClawTheme.primary, ClawTheme.secondary],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 60, height: 60)
                
                Text("🦞")
                    .font(.system(size: 30))
            }
            
            Text("Tap mic to speak")
                .font(.caption)
                .foregroundColor(ClawTheme.textSecondary)
            
            Text("to your AI")
                .font(.caption2)
                .foregroundColor(ClawTheme.textSecondary.opacity(0.7))
            
            Spacer()
        }
    }
    
    var messagesView: some View {
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
    
    var voiceInputView: some View {
        // TextField with dictation support - tap mic icon on keyboard
        TextField("Tap to speak...", text: $messageText)
            .textFieldStyle(.roundedBorder)
            .onSubmit {
                if !messageText.isEmpty {
                    viewModel.sendMessage(messageText)
                    messageText = ""
                }
            }
            .padding(.horizontal, 8)
            .padding(.bottom, 4)
    }
}

// MARK: - Onboarding View
struct OnboardingView: View {
    @Binding var isPresented: Bool
    @State private var currentPage = 0
    
    var body: some View {
        TabView(selection: $currentPage) {
            // Page 1: Welcome
            VStack(spacing: 12) {
                Text("🦞")
                    .font(.system(size: 50))
                Text("ClawWatch")
                    .font(.headline)
                    .foregroundColor(ClawTheme.primary)
                Text("Your AI on your wrist")
                    .font(.caption)
                    .foregroundColor(ClawTheme.textSecondary)
            }
            .tag(0)
            
            // Page 2: How it works
            VStack(spacing: 8) {
                Image(systemName: "mic.fill")
                    .font(.title)
                    .foregroundColor(ClawTheme.secondary)
                Text("Tap & Speak")
                    .font(.caption)
                    .fontWeight(.semibold)
                Text("Tap the text field, then the mic to dictate your message")
                    .font(.caption2)
                    .foregroundColor(ClawTheme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            .tag(1)
            
            // Page 3: Setup
            VStack(spacing: 12) {
                Image(systemName: "gear")
                    .font(.title)
                    .foregroundColor(ClawTheme.primary)
                Text("Quick Setup")
                    .font(.caption)
                    .fontWeight(.semibold)
                Text("Add your Telegram bot token in Settings")
                    .font(.caption2)
                    .foregroundColor(ClawTheme.textSecondary)
                    .multilineTextAlignment(.center)
                
                Button("Get Started") {
                    UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
                    isPresented = false
                }
                .buttonStyle(.borderedProminent)
                .tint(ClawTheme.primary)
            }
            .tag(2)
        }
        .tabViewStyle(.page)
        .background(ClawTheme.background)
    }
}

// MARK: - Message Bubble
struct MessageBubble: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.isFromUser {
                Spacer(minLength: 20)
            }
            
            Text(message.text)
                .font(.caption2)
                .padding(10)
                .background(
                    message.isFromUser
                        ? LinearGradient(colors: [ClawTheme.primary, ClawTheme.secondary], startPoint: .leading, endPoint: .trailing)
                        : LinearGradient(colors: [ClawTheme.surface, ClawTheme.surface], startPoint: .leading, endPoint: .trailing)
                )
                .foregroundColor(.white)
                .cornerRadius(16)
            
            if !message.isFromUser {
                Spacer(minLength: 20)
            }
        }
    }
}

// MARK: - Data Models
struct ChatMessage: Identifiable {
    let id = UUID()
    let text: String
    let isFromUser: Bool
    let timestamp: Date
}

// MARK: - View Model
class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var isLoading = false
    
    private let synthesizer = AVSpeechSynthesizer()
    
    // Telegram Bot Configuration
    private var botToken: String {
        UserDefaults.standard.string(forKey: "telegramBotToken") ?? ""
    }
    private var chatId: String {
        UserDefaults.standard.string(forKey: "telegramChatId") ?? ""
    }
    private var voiceEnabled: Bool {
        UserDefaults.standard.bool(forKey: "voiceResponseEnabled")
    }
    
    func sendMessage(_ text: String) {
        guard !text.isEmpty else { return }
        
        let userMessage = ChatMessage(text: text, isFromUser: true, timestamp: Date())
        DispatchQueue.main.async {
            self.messages.append(userMessage)
        }
        
        // Haptic for send
        WKInterfaceDevice.current().play(.success)
        
        sendToTelegram(text)
    }
    
    private func sendToTelegram(_ text: String) {
        guard !botToken.isEmpty, !chatId.isEmpty else {
            let errorMessage = ChatMessage(
                text: "⚙️ Set up your bot in Settings",
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
        
        // Add context (time, from Watch)
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        let contextText = "[\(timeFormatter.string(from: Date())) via ClawWatch] \(text)"
        
        let body: [String: Any] = [
            "chat_id": chatId,
            "text": contextText
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                if error != nil {
                    let errorMsg = ChatMessage(text: "❌ Failed to send", isFromUser: false, timestamp: Date())
                    self?.messages.append(errorMsg)
                } else {
                    let confirmMsg = ChatMessage(text: "✓ Sent to AI", isFromUser: false, timestamp: Date())
                    self?.messages.append(confirmMsg)
                    
                    // Haptic confirmation
                    WKInterfaceDevice.current().play(.notification)
                }
            }
        }.resume()
    }
    
    func speakResponse(_ text: String) {
        guard voiceEnabled else { return }
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-GB")
        utterance.rate = 0.5
        synthesizer.speak(utterance)
    }
}

// MARK: - Preview
#Preview {
    ContentView()
}
