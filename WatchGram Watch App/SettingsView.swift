import SwiftUI

struct SettingsView: View {
    @AppStorage("telegramBotToken") private var botToken = ""
    @AppStorage("telegramChatId") private var chatId = ""
    @AppStorage("voiceResponseEnabled") private var voiceResponseEnabled = true
    @AppStorage("selectedVoice") private var selectedVoice = "en-GB"
    
    @State private var showingSetupGuide = false
    @State private var showingAbout = false
    
    var isConfigured: Bool {
        !botToken.isEmpty && !chatId.isEmpty
    }
    
    var body: some View {
        List {
            // Status Section
            Section {
                HStack {
                    Image(systemName: isConfigured ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
                        .foregroundColor(isConfigured ? .green : .orange)
                    Text(isConfigured ? "Connected" : "Setup Required")
                        .font(.caption)
                }
            }
            
            // Telegram Section
            Section("Telegram Bot") {
                Button(action: { showingSetupGuide = true }) {
                    HStack {
                        Image(systemName: "questionmark.circle")
                            .foregroundColor(ClawTheme.secondary)
                        Text("Setup Guide")
                            .font(.caption)
                    }
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Bot Token")
                        .font(.caption2)
                        .foregroundColor(ClawTheme.textSecondary)
                    SecureField("Paste token", text: $botToken)
                        .font(.caption)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Chat ID")
                        .font(.caption2)
                        .foregroundColor(ClawTheme.textSecondary)
                    TextField("Your chat ID", text: $chatId)
                        .font(.caption)
                }
            }
            
            // Voice Section
            Section("Voice") {
                Toggle(isOn: $voiceResponseEnabled) {
                    HStack {
                        Image(systemName: "speaker.wave.2")
                            .foregroundColor(ClawTheme.primary)
                        Text("Speak Responses")
                            .font(.caption)
                    }
                }
                
                if voiceResponseEnabled {
                    Picker("Voice", selection: $selectedVoice) {
                        Text("🇬🇧 British").tag("en-GB")
                        Text("🇺🇸 American").tag("en-US")
                        Text("🇦🇺 Australian").tag("en-AU")
                    }
                    .font(.caption)
                }
            }
            
            // About Section
            Section("About") {
                Button(action: { showingAbout = true }) {
                    HStack {
                        Text("🦞")
                        Text("About ClawWatch")
                            .font(.caption)
                    }
                }
                
                HStack {
                    Text("Version")
                        .font(.caption)
                    Spacer()
                    Text("1.0.0")
                        .font(.caption)
                        .foregroundColor(ClawTheme.textSecondary)
                }
            }
        }
        .navigationTitle("Settings")
        .sheet(isPresented: $showingSetupGuide) {
            SetupGuideView()
        }
        .sheet(isPresented: $showingAbout) {
            AboutView()
        }
    }
}

// MARK: - Setup Guide
struct SetupGuideView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Spacer()
                    Text("🤖")
                        .font(.largeTitle)
                    Spacer()
                }
                
                Text("Setup Guide")
                    .font(.headline)
                    .foregroundColor(ClawTheme.primary)
                
                stepView(number: "1", title: "Open Telegram", detail: "Search for @BotFather")
                
                stepView(number: "2", title: "Create Bot", detail: "Send /newbot and follow the prompts")
                
                stepView(number: "3", title: "Copy Token", detail: "BotFather gives you a token like: 123456:ABC-DEF...")
                
                stepView(number: "4", title: "Get Chat ID", detail: "Message @userinfobot - it replies with your ID")
                
                stepView(number: "5", title: "Start Your Bot", detail: "Send any message to YOUR new bot first")
                
                Button("Got It!") {
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .tint(ClawTheme.primary)
                .frame(maxWidth: .infinity)
                .padding(.top)
            }
            .padding()
        }
        .background(ClawTheme.background)
    }
    
    func stepView(number: String, title: String, detail: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Text(number)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(ClawTheme.secondary)
                .frame(width: 20, height: 20)
                .background(ClawTheme.surface)
                .cornerRadius(10)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .fontWeight(.semibold)
                Text(detail)
                    .font(.caption2)
                    .foregroundColor(ClawTheme.textSecondary)
            }
        }
    }
}

// MARK: - About View
struct AboutView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Text("🦞")
                    .font(.system(size: 50))
                
                Text("ClawWatch")
                    .font(.headline)
                    .foregroundColor(ClawTheme.primary)
                
                Text("Voice for AI")
                    .font(.caption)
                    .foregroundColor(ClawTheme.textSecondary)
                
                Divider()
                    .background(ClawTheme.surface)
                
                Text("Talk to your AI assistant hands-free from your Apple Watch.")
                    .font(.caption2)
                    .foregroundColor(ClawTheme.textSecondary)
                    .multilineTextAlignment(.center)
                
                Text("Powered by ClawBot")
                    .font(.caption2)
                    .foregroundColor(ClawTheme.secondary)
                
                Spacer()
                
                Button("Close") {
                    dismiss()
                }
                .buttonStyle(.bordered)
            }
            .padding()
        }
        .background(ClawTheme.background)
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
}
