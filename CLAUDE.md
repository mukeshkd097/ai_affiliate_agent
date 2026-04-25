# Flip-Logic — Mobile App for Car Flippers

## Overview

Flip-Logic is a mobile app (Flutter/FlutterFlow) that helps car flippers make fast, data-driven decisions at auctions and on the lot. It combines AI-powered visual damage assessment with real-time market pricing to estimate profit potential before a purchase.

---

## Core Goals

### 1. VIN Scanning
- Scan a vehicle's VIN barcode using the device camera
- Decode the VIN to retrieve year, make, model, trim, and standard equipment
- Feed decoded VIN data into downstream pricing and history lookups

### 2. AI Damage Assessment — Gemini 1.5 Vision
- Allow the user to photograph the vehicle (exterior panels, interior, undercarriage)
- Send images to **Google Gemini 1.5 Vision** API for analysis
- Return a structured damage report:
  - Detected damage items (dents, scratches, rust, glass, mechanical)
  - Estimated repair cost range per item
  - Overall condition score
- Surface the damage summary alongside the profit estimate

### 3. Market Pricing — Marketcheck API
- Query the **Marketcheck** API using the decoded VIN (or year/make/model)
- Retrieve:
  - Average retail / wholesale / auction prices
  - Active listings and days-on-market data
  - Regional price trends
- Combine pricing data with the damage repair estimate to calculate:
  - Estimated resale value
  - Maximum allowable purchase price (MAPP)
  - Projected gross profit

---

## Tech Stack

| Layer | Choice |
|---|---|
| Frontend | Flutter (via FlutterFlow) |
| VIN Decode | NHTSA free API or paid VIN decoder |
| Damage AI | Google Gemini 1.5 Vision API |
| Pricing | Marketcheck API |
| Backend / Auth | Firebase (Auth + Firestore) |
| State Management | Riverpod or FlutterFlow state |

---

## Key Screens

1. **Home / Dashboard** — recent scans, quick-action buttons
2. **VIN Scanner** — camera barcode scanner
3. **Photo Capture** — multi-angle photo upload flow
4. **Damage Report** — Gemini Vision results, itemized repair costs
5. **Pricing Report** — Marketcheck data, MAPP calculator
6. **Deal Summary** — combined profit estimate, save/share deal

---

## Integration Notes

- Gemini 1.5 Vision requests should batch photos per vehicle to minimize API calls
- Marketcheck pricing should cache results per VIN for the session to avoid redundant lookups
- All API keys must be stored in Firebase Remote Config or environment secrets — never hardcoded

---

## Development Setup

```bash
# Clone the repo
git clone https://github.com/mukeshkd097/ai_affiliate_agent.git
cd ai_affiliate_agent
git checkout claude/setup-flip-logic-app-aPzzH

# Flutter dependencies
flutter pub get

# Run on a connected device or emulator
flutter run
```

---

## Environment Variables Required

```
GEMINI_API_KEY=<your Gemini 1.5 Vision API key>
MARKETCHECK_API_KEY=<your Marketcheck API key>
FIREBASE_PROJECT_ID=<your Firebase project ID>
```
