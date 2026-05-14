# SnapSort AI

> AI-powered screenshot organiser for Android & iOS — auto-categorises your screenshots into 11 smart folders so you never lose an OTP, receipt, or note again.

## What it does

SnapSort AI scans your gallery and uses **on-device OCR + rule-based AI** to file each screenshot into a named folder:

| Folder | What goes in |
|---|---|
| 🔐 OTP | 4-8 digit one-time passwords |
| 💡 Bills | Electricity, internet, phone bills |
| 🧾 Receipts | Order confirmations, payment receipts |
| 😂 Memes | Funny images & GIF screenshots |
| 📝 Notes | To-dos, reminders, ideas |
| 📈 Trading | Zerodha, Groww, Upstox P&L |
| 🏦 Bank Info | Account numbers, IFSC, statements |
| 🎫 Tickets | PNR, flight/movie/bus tickets |
| 🛍 Shopping | Amazon, Flipkart, Zomato orders |
| ₿ Crypto | Bitcoin, Ethereum, WazirX |
| 📁 Misc | Everything else |

## Tech stack

| Layer | Choice | Reason |
|---|---|---|
| Framework | Flutter 3.x | Single codebase for Android + iOS |
| State | flutter_bloc | Predictable, testable, scalable |
| AI/OCR | Google ML Kit Text Recognition | On-device, free, accurate |
| Database | SQLite (sqflite) + FTS5 | Fast local search |
| Photos | photo_manager | Cross-platform gallery access |
| Subscriptions | in_app_purchase (future) | Native billing |

## Project structure

```
snapsort_ai/
├── lib/
│   ├── main.dart                  # App entry point
│   ├── models/                    # Data models
│   ├── constants/                 # Keyword lists, config
│   ├── services/
│   │   ├── category_service.dart  # OCR + rule-based classifier
│   │   ├── database_service.dart  # SQLite + FTS
│   │   ├── photo_service.dart     # Gallery access
│   │   └── subscription_service.dart
│   ├── bloc/screenshot/           # BLoC state management
│   ├── screens/
│   │   ├── onboarding/            # 4-step onboarding flow
│   │   ├── home/                  # Grid + category chips
│   │   ├── category/              # Per-category view
│   │   ├── search/                # FTS search screen
│   │   ├── detail/                # Full-screen viewer
│   │   └── pro/                   # Subscription page
│   ├── widgets/                   # Reusable components
│   └── theme/                     # Material 3 light + dark
├── android/
└── ios/
```

## Getting started

```bash
# Install dependencies
flutter pub get

# Run on connected device or emulator
flutter run

# Build release APK
flutter build apk --release

# Build iOS (requires macOS + Xcode)
flutter build ios --release
```

## Monetisation

| Tier | Limit | Price |
|---|---|---|
| Free | 500 screenshots | ₹0 |
| Pro Monthly | Unlimited | ₹99/month |
| Pro Yearly | Unlimited + cloud backup | ₹799/year |
| Pro Lifetime | Everything | ₹1,999 |

## Privacy

All AI processing happens **on-device** via Google ML Kit. Screenshots are never uploaded to any server without explicit user consent (cloud backup requires Pro + opt-in).

## Roadmap

- v1.1 — Cloud backup, PDF export, widget for quick OTP access
- v2.0 — On-device LLM for deeper semantic search, shared albums
