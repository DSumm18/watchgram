# WatchGram - Business Plan

## Product Vision

**The AI assistant on your wrist.**

Voice-to-voice Telegram messaging from Apple Watch. Perfect for AI assistants (ClawBot, etc.) - speak, get answers, hear responses.

---

## Market Opportunity

**Why now:**
1. AI assistants exploding (ChatGPT, Claude, ClawBot)
2. Telegram growing as AI interface channel
3. Apple Watch Series 10 has improved speakers
4. No quality Telegram Watch app exists
5. Voice interaction is the natural Watch UX

**Target users:**
- AI assistant users (ClawBot, OpenClaw, etc.)
- Busy professionals wanting hands-free messaging
- Telegram power users
- Apple Watch enthusiasts

---

## Features

### MVP (Week 1)
- [x] Voice-to-text input
- [x] Send messages via Telegram Bot API
- [x] Simple message history on Watch
- [x] Settings for Bot Token/Chat ID
- [ ] Confirmation of sent messages

### v1.1 (Week 2)
- [ ] Receive incoming messages (polling)
- [ ] Text-to-speech for responses (native)
- [ ] Complications for quick access
- [ ] Haptic notifications

### v2.0 (Future)
- [ ] Multiple chat support
- [ ] Premium voices (ElevenLabs integration)
- [ ] Siri Shortcuts integration
- [ ] iPhone companion app

---

## Monetization

### Pricing Strategy

**Option A: Simple One-Time**
- £4.99 unlock all features
- Simple, high conversion

**Option B: Freemium + Subscription (Recommended)**
- Free: 10 messages/day, text only
- Pro (£4.99 one-time): Unlimited messages
- Voice Pack (£2.99/month): Premium TTS voices

**Projected Revenue:**
| Scenario | Downloads/mo | Conversion | Revenue |
|----------|--------------|------------|---------|
| Low | 200 | 10% | £100/mo |
| Medium | 1,000 | 10% | £500/mo |
| High | 5,000 | 10% | £2,500/mo |

---

## Technical Architecture

**Watch App (SwiftUI + WatchOS 10)**
```
┌─────────────────────┐
│   Apple Watch       │
│  ┌───────────────┐  │
│  │ Speech-to-Text│  │
│  │   (Native)    │  │
│  └───────┬───────┘  │
│          ▼          │
│  ┌───────────────┐  │
│  │ Telegram Bot  │  │
│  │     API       │──┼──► Telegram
│  └───────────────┘  │
│          ▲          │
│  ┌───────────────┐  │
│  │ Text-to-Speech│  │
│  │   (Native)    │  │
│  └───────────────┘  │
└─────────────────────┘
```

**No backend required** - Direct Bot API calls from Watch.

---

## App Store Strategy

**Name:** WatchGram - Voice for Telegram

**Subtitle:** Talk to your AI assistant

**Keywords:**
- Telegram Watch
- Voice Telegram
- AI assistant Watch
- WatchOS Telegram
- Hands-free messaging
- Voice messages

**Screenshots needed:**
1. Main chat view with mic button
2. Speaking animation
3. Response being played
4. Settings/setup screen

**Positioning:**
Not just "Telegram on Watch" but specifically "Voice assistant for AI bots"

---

## Launch Strategy

**Week 1:** Build & Internal Testing
**Week 2:** TestFlight Beta (David tests)
**Week 3:** Polish & Submit
**Week 4:** Launch

**Marketing:**
- Post in OpenClaw/ClawBot communities
- Telegram channels about AI assistants
- Watch app review sites
- Reddit r/AppleWatch, r/Telegram

---

## Risks & Mitigations

| Risk | Mitigation |
|------|------------|
| Apple rejects for Telegram trademark | Use generic name, focus on "Bot API client" |
| Telegram changes API | Bot API is stable, well-documented |
| Low discovery on App Store | Strong ASO, community marketing |
| Complex setup (Bot Token) | Clear in-app guide, video tutorial |

---

## Success Metrics

**Month 1:**
- 500+ downloads
- 4.5+ star rating
- £200+ revenue

**Month 6:**
- 5,000+ downloads
- Featured in "Watch Apps" section
- £1,000+/month recurring

**Year 1:**
- 20,000+ downloads
- £10,000+ total revenue
- Established as go-to Watch Telegram client

---

*Created: 2026-01-31*
*Status: In Development*
*Priority: HIGH*
