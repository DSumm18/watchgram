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
    @State private var showingInput = false
    
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
        VStack {
            Spacer()
            
            // Lobster mic button - centered, clean, simple
            Button(action: { showingInput = true }) {
                ZStack {
                    // Pulsing outer ring
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [ClawTheme.primary, ClawTheme.secondary],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 4
                        )
                        .frame(width: 120, height: 120)
                    
                    // Inner circle
                    Circle()
                        .fill(ClawTheme.surface)
                        .frame(width: 108, height: 108)
                    
                    // Lobster + mic icon
                    VStack(spacing: 6) {
                        Text("🦞")
                            .font(.system(size: 50))
                        Image(systemName: "mic.fill")
                            .font(.callout)
                            .foregroundColor(ClawTheme.secondary)
                    }
                }
            }
            .buttonStyle(.plain)
            .fullScreenCover(isPresented: $showingInput) {
                ChatScreen(viewModel: viewModel, isPresented: $showingInput)
            }
            
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
        // Only show when we have messages (in conversation)
        Group {
            if !viewModel.messages.isEmpty {
                HStack(spacing: 8) {
                    TextField("Tap to speak...", text: $messageText)
                        .onSubmit {
                            if !messageText.isEmpty {
                                viewModel.sendMessage(messageText)
                                messageText = ""
                            }
                        }
                    
                    if !messageText.isEmpty {
                        Button(action: {
                            viewModel.sendMessage(messageText)
                            messageText = ""
                        }) {
                            Image(systemName: "arrow.up.circle.fill")
                                .font(.title3)
                                .foregroundColor(ClawTheme.primary)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 8)
                .padding(.bottom, 4)
            }
        }
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
                    .font(.system(size: 60))
                Text("Hey! I'm Ed")
                    .font(.headline)
                    .foregroundColor(ClawTheme.primary)
                Text("Your AI buddy, now on your wrist!")
                    .font(.caption2)
                    .foregroundColor(ClawTheme.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .tag(0)
            
            // Page 2: How it works
            VStack(spacing: 10) {
                Image(systemName: "waveform")
                    .font(.largeTitle)
                    .foregroundColor(ClawTheme.secondary)
                Text("Just Talk")
                    .font(.caption)
                    .fontWeight(.bold)
                Text("Speak naturally.\nI'll listen & respond.")
                    .font(.caption2)
                    .foregroundColor(ClawTheme.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .tag(1)
            
            // Page 3: Setup
            VStack(spacing: 10) {
                Text("🔗")
                    .font(.largeTitle)
                Text("Quick Connect")
                    .font(.caption)
                    .fontWeight(.bold)
                Text("Message @ClawWatchSetup_bot\non Telegram for your code")
                    .font(.caption2)
                    .foregroundColor(ClawTheme.textSecondary)
                    .multilineTextAlignment(.center)
                
                Button("Let's Go! 🦞") {
                    UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
                    isPresented = false
                }
                .buttonStyle(.borderedProminent)
                .tint(ClawTheme.primary)
                .padding(.top, 8)
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
        HStack(alignment: .top, spacing: 6) {
            if message.isFromUser {
                Spacer(minLength: 15)
            } else {
                // Ed's avatar
                Text("🦞")
                    .font(.caption)
            }
            
            VStack(alignment: message.isFromUser ? .trailing : .leading, spacing: 2) {
                Text(message.text)
                    .font(.caption2)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .background(
                        message.isFromUser
                            ? LinearGradient(colors: [ClawTheme.primary, ClawTheme.secondary], startPoint: .leading, endPoint: .trailing)
                            : LinearGradient(colors: [ClawTheme.surface.opacity(0.8), ClawTheme.surface], startPoint: .leading, endPoint: .trailing)
                    )
                    .foregroundColor(.white)
                    .cornerRadius(14)
            }
            
            if !message.isFromUser {
                Spacer(minLength: 15)
            }
        }
    }
}

// MARK: - Chat Screen (Full conversation view)
struct ChatScreen: View {
    @ObservedObject var viewModel: ChatViewModel
    @Binding var isPresented: Bool
    @State private var messageText = ""
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: { isPresented = false }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title3)
                        .foregroundColor(ClawTheme.textSecondary)
                }
                Spacer()
                Text("🦞 Ed")
                    .font(.caption)
                    .fontWeight(.semibold)
                Spacer()
                // Balance spacer
                Image(systemName: "xmark.circle.fill")
                    .font(.title3)
                    .foregroundColor(.clear)
            }
            .padding(.horizontal, 8)
            .padding(.top, 4)
            
            // Messages
            if viewModel.messages.isEmpty {
                Spacer()
                Text("Say something!")
                    .font(.caption)
                    .foregroundColor(ClawTheme.textSecondary)
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
            
            // Voice input - BIG mic button
            HStack(spacing: 8) {
                TextField("Tap mic →", text: $messageText)
                    .font(.caption)
                    .frame(height: 36)
                    .onSubmit {
                        sendIfNotEmpty()
                    }
                
                // Mic/Send button
                Button(action: sendIfNotEmpty) {
                    ZStack {
                        Circle()
                            .fill(messageText.isEmpty ? ClawTheme.secondary : ClawTheme.primary)
                            .frame(width: 36, height: 36)
                        
                        Image(systemName: messageText.isEmpty ? "mic.fill" : "arrow.up")
                            .font(.body)
                            .foregroundColor(.white)
                    }
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 8)
            .padding(.bottom, 4)
        }
        .background(ClawTheme.background)
    }
    
    func sendIfNotEmpty() {
        guard !messageText.isEmpty else { return }
        viewModel.sendMessage(messageText)
        messageText = ""
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
    private var pollTimer: Timer?
    
    // Connection state (from 6-digit code setup)
    private var isConnected: Bool {
        UserDefaults.standard.bool(forKey: "isConnected")
    }
    private var chatId: String {
        UserDefaults.standard.string(forKey: "chatId") ?? ""
    }
    private var sessionToken: String {
        UserDefaults.standard.string(forKey: "sessionToken") ?? ""
    }
    private var voiceEnabled: Bool {
        UserDefaults.standard.bool(forKey: "voiceResponseEnabled")
    }
    
    init() {
        startPolling()
    }
    
    deinit {
        pollTimer?.invalidate()
    }
    
    func startPolling() {
        // Poll for new messages every 3 seconds
        pollTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { [weak self] _ in
            self?.fetchMessages()
        }
    }
    
    func fetchMessages() {
        guard isConnected, !chatId.isEmpty else { return }
        
        let urlString = "https://clawwatch-setup.vercel.app/api/messages?chatId=\(chatId)"
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let data = data, error == nil else { return }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let success = json["success"] as? Bool, success,
                   let messages = json["messages"] as? [[String: Any]] {
                    
                    for msg in messages {
                        if let text = msg["text"] as? String {
                            DispatchQueue.main.async {
                                let response = ChatMessage(text: text, isFromUser: false, timestamp: Date())
                                self?.messages.append(response)
                                
                                // Haptic for received message
                                WKInterfaceDevice.current().play(.notification)
                                
                                // Speak response if enabled
                                self?.speakResponse(text)
                            }
                        }
                    }
                }
            } catch {
                print("Parse error: \(error)")
            }
        }.resume()
    }
    
    func sendMessage(_ text: String) {
        guard !text.isEmpty else { return }
        
        let userMessage = ChatMessage(text: text, isFromUser: true, timestamp: Date())
        DispatchQueue.main.async {
            self.messages.append(userMessage)
        }
        
        // Haptic for send
        WKInterfaceDevice.current().play(.success)
        
        sendToAPI(text)
    }
    
    private func sendToAPI(_ text: String) {
        guard isConnected, !chatId.isEmpty else {
            let errorMessage = ChatMessage(
                text: "⚙️ Connect in Settings first",
                isFromUser: false,
                timestamp: Date()
            )
            DispatchQueue.main.async {
                self.messages.append(errorMessage)
            }
            return
        }
        
        // Send via relay API
        let urlString = "https://clawwatch-setup.vercel.app/api/send"
        guard let url = URL(string: urlString) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "chatId": chatId,
            "sessionToken": sessionToken,
            "message": text
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                if error != nil {
                    let errorMsg = ChatMessage(text: "❌ Failed to send", isFromUser: false, timestamp: Date())
                    self?.messages.append(errorMsg)
                } else {
                    // Don't show "Sent to Ed" - just wait for response
                    // Haptic confirmation
                    WKInterfaceDevice.current().play(.notification)
                    
                    // Fetch messages immediately after sending
                    self?.fetchMessages()
                }
            }
        }.resume()
    }
    
    func speakResponse(_ text: String) {
        // Always speak responses on Watch - that's the point!
        let cleanText = text
            .replacingOccurrences(of: "🦞", with: "")
            .replacingOccurrences(of: "⌚", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !cleanText.isEmpty else { return }
        
        let utterance = AVSpeechUtterance(string: cleanText)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-GB")
        utterance.rate = 0.52
        utterance.pitchMultiplier = 1.0
        utterance.volume = 1.0
        synthesizer.speak(utterance)
    }
}

// MARK: - Preview
#Preview {
    ContentView()
}
