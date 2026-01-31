# ClawWatch - Ready for Testing 🦞⌚

## What's Done

### ✅ App Features
- Voice-to-text input (tap mic, speak)
- Send messages to Telegram bot
- Message history on Watch
- Text-to-speech responses (optional)
- Beautiful ClawBot-themed UI (purple/cyan gradients)
- Onboarding flow for new users
- Settings for bot configuration
- Haptic feedback throughout
- Context aware (adds time to messages)

### ✅ Branding
- App name: ClawWatch
- Tagline: "Voice for AI"
- ClawBot styling (dark + neon)
- 🦞 Claw icon throughout

### ✅ Infrastructure
- GitHub repo: https://github.com/DSumm18/watchgram
- GitHub Actions building on macOS ✅
- XcodeGen project generation ✅
- Team ID configured: J7R6QL77M4

### ✅ App Store Assets
- Full description written
- Keywords optimized
- Screenshot concepts defined

---

## What You Need To Do

### Step 1: Create App in App Store Connect (2 mins)

1. Go to https://appstoreconnect.apple.com
2. Click "Apps" → "+" → "New App"
3. Fill in:
   - Platform: watchOS
   - Name: ClawWatch - Voice for AI
   - Primary Language: English (UK)
   - Bundle ID: com.dsumm.clawwatch.watchkitapp
   - SKU: clawwatch-001
4. Click "Create"

### Step 2: Set Up Code Signing

We need an App Store Connect API key for automated uploads.

1. In App Store Connect → Users and Access → Integrations
2. Click "App Store Connect API" → "+" to generate key
3. Role: Admin or App Manager
4. Download the .p8 file
5. Note the Key ID and Issuer ID

Share these with Ed (me) and I'll add them as GitHub secrets.

### Step 3: Test on Your Watch

Once signing is set up:
1. I push a TestFlight build
2. You get notification on your iPhone
3. Open TestFlight, install on Watch
4. Speak to me through your wrist! 🎤

---

## Quick Setup Guide (For You)

### Setting Up Your Telegram Bot

1. Open Telegram
2. Search for @BotFather
3. Send: /newbot
4. Follow prompts (give it a name)
5. Copy the token it gives you
6. Message @userinfobot to get your Chat ID
7. Enter both in ClawWatch settings

That's it! Now when you speak to your Watch, it messages your bot (which can be connected to ClawBot/OpenClaw).

---

## Revenue Model

**Option A: Paid App £4.99**
- All features included
- Simple, no subscriptions
- Higher perceived value

**Option B: Freemium**
- Free: 10 messages/day
- Pro £4.99: Unlimited + voice responses

*Recommend: Start with paid app, simpler.*

---

## Timeline

- **Today:** You create app in App Store Connect, share API key
- **Tonight:** I push signed build to TestFlight
- **Tomorrow:** You test on your Watch
- **Next few days:** Polish based on feedback
- **Submit:** Mid next week

---

## Commands for Ed

If you need me to do anything:
- "Push a new build" - I'll commit and trigger GitHub Actions
- "Check build status" - I'll show the latest run
- "Add feature X" - I'll code it and push

---

*Everything is ready. Just need App Store Connect setup! 🚀*
