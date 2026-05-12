# BobaLoyalty — Minimal PRD

> Bubble tea shop loyalty app. Source material for the ShipSwift video walkthrough released on 2026-05-12.

## Who It's For

Brick-and-mortar bubble tea shop owners. A replacement for the off-the-shelf monthly-fee SaaS systems on the market (expensive, and your data isn't really yours).

## Dual Roles

- **Customer side (consumer, primary battleground)**: scan in-store QR code → browse menu → place + pay → earn points → receive birthday coupons
- **Owner side (B-side, simplified)**: menu management + bulk birthday coupon broadcast + revenue dashboard

## 6 Core Modules

| # | Module | Customer Side | Owner Side |
|---|------|--------|--------|
| 1 | Login | Anonymous-first, scan QR to instantly issue membership card (phone number not required) | Apple Sign In |
| 2 | Menu | Browse by category (image + name + price + spec) | Editable products (image + name + price + spec like ice/sugar + category) |
| 3 | Order + Pay | Pick → add to cart → choose spec → place → pay via WeChat/Alipay | View live orders |
| 4 | Points | +10 per cup, free cup at 100 | View member point totals |
| 5 | Birthday Coupon | Receive + redeem | One-tap bulk birthday coupon broadcast |
| 6 | Purchase History | View own past orders | View daily revenue |

## Tech Stack

- **iOS 17+ SwiftUI**
- **Must build on ShipSwift recipes** — maximize component reuse (login / payment / list cards / forms etc. all snap together from existing modules)
- Backend (out of scope for this open-sourced demo, see PRD only): would use ShipSwift's standard `infra-cdk` recipe (Cognito anonymous auth + DynamoDB + StoreKit). The open-source build is local SwiftData mock only.

## Visual Style

- Primary: warm tea-shop tones (ivory / caramel / milk-tea brown)
- Assets: bubble tea photography (Unsplash CC0 or AI-generated)

## MVP Scope

**In scope**:
- End-to-end loop: order + points + birthday coupon
- Complete demoable customer-side UI
- Owner-side MVP (menu edit + coupon broadcast + revenue dashboard)

**Out of scope**:
- Delivery, multi-store chains, complex membership tiers, courier dispatch
- Production-grade robustness (no e2e tests, no CI, no precise error handling)

## Engineering Goal

Source material for the 2026-05-12 video walkthrough — the model runs through a fresh generation pass on Cursor / Claude Code while the final app is demoed live. **The point is "AI can compose this + it looks like a real app"** — production-grade robustness is not required.
