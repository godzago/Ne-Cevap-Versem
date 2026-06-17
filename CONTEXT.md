# CONTEXT.md — "Ne Cevap Vereyim?" Flutter App

## Project Identity

**App Name:** Ne Cevap Vereyim? (screat_app)  
**Type:** Flutter Mobile App (Cross-platform, Android-first then iOS)  
**Language:** Dart / Flutter  
**Status:** MVP Development Phase

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Frontend | Flutter & Dart |
| Architecture | MVVM / Clean Architecture |
| State Management | Riverpod or BLoC |
| Backend / Proxy | Firebase Cloud Functions (Node.js) |
| AI APIs | Gemini Free Tier, Groq Cloud, Hugging Face (routed via proxy) |
| Monetization | RevenueCat (purchases_flutter) |
| Secure Storage | flutter_secure_storage |
| Image Upload | image_picker |
| Config | flutter_dotenv |

## Repository Structure

```
screat_app/
├── lib/                    # Dart source code
│   ├── main.dart          # App entry point
│   └── ...                # Feature modules
├── assets/                # Images, fonts, static assets
├── android/               # Android platform code
├── ios/                   # iOS platform code
├── test/                  # Unit & widget tests
├── pubspec.yaml           # Flutter dependencies
├── .env                   # Environment variables (API keys)
├── PROJECT.md             # Full project specification
└── .agent/                # GSD agent configuration
    └── skills/            # 67 GSD skills installed here
```

## App Architecture — 4 AI Personas / Modes

| Mode | Name | Audience | Tone |
|------|------|----------|------|
| 1 | Patron / Yönetici (Corporate Diplomat) | Corporate workers, freelancers | Professional, firm, politically correct |
| 2 | Sevgili / Flört (Romantic Navigator) | Dating / relationships | Empathetic, flirty, clear |
| 3 | Pasif-Agresif (Sarcastic Duo) | Toxic friends, trolls | Sharp, witty, passive-aggressive |
| 4 | Mülakat (HR Specialist) | Job seekers | Confident, structured |

Each mode generates **3 response options**:
- Option A: Safe & Polite (Politik & Kibar)
- Option B: Short & Direct (Net & Kısa)  
- Option C: Witty / Creative (Yaratıcı / Esprili)

## Critical Security Rules

- **NEVER** call OpenAI/Anthropic/Gemini directly from Flutter client
- **ALL** AI requests MUST route through Firebase Cloud Functions proxy
- **DO NOT** commit `.env` files or API keys to git

## Monetization Rules

- **Daily Free Limit:** 3 standard text replies/day (resets 00:00 UTC)
- **Premium-Only:** Mode 1 (Patron), Mode 4 (Mülakat), ALL image/OCR requests
- **Entitlement ID:** `premium_access`
- **Storage keys:** `int_remaining_credits` (default: 3), `string_last_request_date`

## Development Commands

```bash
# Run on emulator/device
flutter run

# Run tests
flutter test

# Get dependencies
flutter pub get

# Build APK (release)
flutter build apk --release

# Analyze code
flutter analyze
```

## Current Sprint / Focus

- MVP implementation of the 4 modes
- Dashboard (Home Screen) with caricature grid layout
- Chat interface with text input + image upload
- Backend proxy setup (Firebase Cloud Functions)
- RevenueCat integration

## GSD Workflow Commands

Use these slash commands when working on this project:

| Command | Purpose |
|---------|---------|
| `/gsd-quick` | Quick ad-hoc tasks with GSD guarantees |
| `/gsd-execute-phase` | Execute a planned phase |
| `/gsd-plan-phase` | Plan a new phase |
| `/gsd-debug` | Debug issues |
| `/gsd-code-review` | Review code quality |
| `/gsd-health` | Check project health |
| `/gsd-progress` | Show current progress |

## AI Response Format (Backend Contract)

```json
{
  "system_prompt": "Sen 'Ne Cevap Vereyim?' uygulamasının [MOD_ADI] yapay zeka asistanısın...",
  "response_format": {
    "option_1_kibar": "Politik ve profesyonel/kibar cevap metni...",
    "option_2_net": "Kısa, net ve doğrudan cevap metni...",
    "option_3_yaratici": "Esprili, yaratıcı veya duruma göre zekice cevap metni..."
  }
}
```
