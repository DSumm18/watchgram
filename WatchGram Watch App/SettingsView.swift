import SwiftUI

struct SettingsView: View {
    @AppStorage("telegramBotToken") private var botToken = ""
    @AppStorage("telegramChatId") private var chatId = ""
    @AppStorage("voiceResponseEnabled") private var voiceResponseEnabled = false
    @AppStorage("selectedVoice") private var selectedVoice = "en-GB"
    
    @State private var showingHelp = false
    
    var body: some View {
        List {
            Section("Telegram Bot") {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Bot Token")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    TextField("Enter token", text: $botToken)
                        .font(.caption)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Chat ID")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    TextField("Enter chat ID", text: $chatId)
                        .font(.caption)
                }
                
                Button("Setup Help") {
                    showingHelp = true
                }
                .font(.caption)
            }
            
            Section("Voice") {
                Toggle("Voice Responses", isOn: $voiceResponseEnabled)
                    .font(.caption)
                
                if voiceResponseEnabled {
                    Picker("Voice", selection: $selectedVoice) {
                        Text("UK English").tag("en-GB")
                        Text("US English").tag("en-US")
                        Text("Australian").tag("en-AU")
                    }
                    .font(.caption)
                }
            }
            
            Section("About") {
                HStack {
                    Text("Version")
                        .font(.caption)
                    Spacer()
                    Text("1.0.0")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .navigationTitle("Settings")
        .sheet(isPresented: $showingHelp) {
            SetupHelpView()
        }
    }
}

struct SetupHelpView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Setup Guide")
                    .font(.headline)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("1. Open Telegram")
                        .font(.caption)
                        .fontWeight(.semibold)
                    Text("Search for @BotFather")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("2. Create Bot")
                        .font(.caption)
                        .fontWeight(.semibold)
                    Text("Send /newbot and follow prompts")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("3. Copy Token")
                        .font(.caption)
                        .fontWeight(.semibold)
                    Text("BotFather will give you a token")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("4. Get Chat ID")
                        .font(.caption)
                        .fontWeight(.semibold)
                    Text("Message @userinfobot for your ID")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                Button("Done") {
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .frame(maxWidth: .infinity)
                .padding(.top)
            }
            .padding()
        }
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
}
