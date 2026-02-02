import SwiftUI

// MARK: - Settings View (v2 - Simple Code Setup)
struct SettingsViewV2: View {
    @AppStorage("isConnected") private var isConnected = false
    @AppStorage("connectedUserId") private var connectedUserId = ""
    @AppStorage("connectedUsername") private var connectedUsername = ""
    @AppStorage("sessionToken") private var sessionToken = ""
    
    @State private var setupCode = ""
    @State private var isVerifying = false
    @State private var errorMessage: String?
    @State private var showingSetupGuide = false
    @State private var showingDisconnectConfirm = false
    
    var body: some View {
        List {
            // Status Section
            Section {
                HStack {
                    Image(systemName: isConnected ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
                        .foregroundColor(isConnected ? .green : .orange)
                    Text(isConnected ? "Connected" : "Not Connected")
                        .font(.caption)
                }
                
                if isConnected && !connectedUsername.isEmpty {
                    HStack {
                        Image(systemName: "person.circle")
                            .foregroundColor(ClawTheme.secondary)
                        Text("@\(connectedUsername)")
                            .font(.caption)
                            .foregroundColor(ClawTheme.textSecondary)
                    }
                }
            }
            
            // Setup Section (when not connected)
            if !isConnected {
                Section("Connect Your Watch") {
                    // Setup guide button
                    Button(action: { showingSetupGuide = true }) {
                        HStack {
                            Image(systemName: "questionmark.circle")
                                .foregroundColor(ClawTheme.secondary)
                            Text("How to Connect")
                                .font(.caption)
                        }
                    }
                    
                    // Code entry
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Enter 6-digit code")
                            .font(.caption2)
                            .foregroundColor(ClawTheme.textSecondary)
                        
                        TextField("000000", text: $setupCode)
                            .font(.system(.title3, design: .monospaced))
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.center)
                            .onChange(of: setupCode) { newValue in
                                // Limit to 6 digits
                                if newValue.count > 6 {
                                    setupCode = String(newValue.prefix(6))
                                }
                                // Only allow numbers
                                setupCode = newValue.filter { $0.isNumber }
                            }
                        
                        if let error = errorMessage {
                            Text(error)
                                .font(.caption2)
                                .foregroundColor(.red)
                        }
                    }
                    
                    // Connect button
                    Button(action: verifyCode) {
                        HStack {
                            if isVerifying {
                                ProgressView()
                                    .scaleEffect(0.8)
                            } else {
                                Image(systemName: "link")
                            }
                            Text(isVerifying ? "Connecting..." : "Connect")
                                .font(.caption)
                        }
                    }
                    .disabled(setupCode.count != 6 || isVerifying)
                    .buttonStyle(.borderedProminent)
                    .tint(ClawTheme.primary)
                }
            }
            
            // Connected options
            if isConnected {
                Section("Account") {
                    Button(action: { showingDisconnectConfirm = true }) {
                        HStack {
                            Image(systemName: "link.badge.minus")
                                .foregroundColor(.red)
                            Text("Disconnect")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                }
            }
            
            // About Section
            Section("About") {
                HStack {
                    Text("🦞")
                    Text("ClawWatch")
                        .font(.caption)
                    Spacer()
                    Text("v2.0")
                        .font(.caption2)
                        .foregroundColor(ClawTheme.textSecondary)
                }
            }
        }
        .navigationTitle("Settings")
        .sheet(isPresented: $showingSetupGuide) {
            SetupGuideViewV2()
        }
        .alert("Disconnect?", isPresented: $showingDisconnectConfirm) {
            Button("Cancel", role: .cancel) { }
            Button("Disconnect", role: .destructive) {
                disconnect()
            }
        } message: {
            Text("You'll need to get a new code to reconnect.")
        }
    }
    
    // MARK: - Actions
    
    func verifyCode() {
        guard setupCode.count == 6 else { return }
        
        isVerifying = true
        errorMessage = nil
        
        // API endpoint (update for production)
        let apiURL = URL(string: "https://clawwatch-api.schoolgle.co.uk/api/verify-code")!
        
        var request = URLRequest(url: apiURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder().encode(["code": setupCode])
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isVerifying = false
                
                if let error = error {
                    errorMessage = "Network error"
                    print("Verify error: \(error)")
                    return
                }
                
                guard let data = data else {
                    errorMessage = "No response"
                    return
                }
                
                do {
                    let result = try JSONDecoder().decode(VerifyResponse.self, from: data)
                    
                    if result.success, let config = result.config {
                        // Save connection info
                        connectedUserId = String(config.userId)
                        connectedUsername = config.username ?? ""
                        sessionToken = config.sessionToken ?? ""
                        isConnected = true
                        setupCode = ""
                        
                        // Haptic feedback
                        WKInterfaceDevice.current().play(.success)
                    } else {
                        errorMessage = result.error ?? "Invalid code"
                        WKInterfaceDevice.current().play(.failure)
                    }
                } catch {
                    errorMessage = "Invalid response"
                    print("Decode error: \(error)")
                }
            }
        }.resume()
    }
    
    func disconnect() {
        isConnected = false
        connectedUserId = ""
        connectedUsername = ""
        sessionToken = ""
    }
}

// MARK: - API Response Models

struct VerifyResponse: Codable {
    let success: Bool
    let error: String?
    let config: ConnectionConfig?
}

struct ConnectionConfig: Codable {
    let userId: Int
    let chatId: Int
    let username: String?
    let firstName: String?
    let apiEndpoint: String?
    let sessionToken: String?
}

// MARK: - Setup Guide v2

struct SetupGuideViewV2: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Spacer()
                    Text("🦞")
                        .font(.largeTitle)
                    Spacer()
                }
                
                Text("Easy Setup")
                    .font(.headline)
                    .foregroundColor(ClawTheme.primary)
                
                stepView(number: "1", 
                        title: "Open Telegram", 
                        detail: "On your phone")
                
                stepView(number: "2", 
                        title: "Message the bot", 
                        detail: "Search: @ClawWatchSetup")
                
                stepView(number: "3", 
                        title: "Get your code", 
                        detail: "Send /connect to get a 6-digit code")
                
                stepView(number: "4", 
                        title: "Enter code here", 
                        detail: "Type the 6 digits on your Watch")
                
                Text("That's it! 🎉")
                    .font(.caption)
                    .foregroundColor(ClawTheme.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                
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
                .foregroundColor(.white)
                .frame(width: 24, height: 24)
                .background(ClawTheme.primary)
                .cornerRadius(12)
            
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

#Preview {
    NavigationStack {
        SettingsViewV2()
    }
}
