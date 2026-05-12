<div align="center">

### ⭐ Built with [**ShipSwift**](https://github.com/signerlabs/ShipSwift) — the open-source Swift recipe library for vibe-coding iOS apps

**If this demo is useful to you, please [give ShipSwift a ⭐ on GitHub](https://github.com/signerlabs/ShipSwift).**
*Stars on the main repo are what keep this whole library moving.*

[![Star ShipSwift on GitHub](https://img.shields.io/github/stars/signerlabs/ShipSwift?style=for-the-badge&logo=github&label=Star%20ShipSwift&color=FFD700)](https://github.com/signerlabs/ShipSwift)

</div>

---

# BobaLoyalty

> A bubble tea shop loyalty app — vibe-coded in a single afternoon with [ShipSwift](https://github.com/signerlabs/ShipSwift).
> Source material for the ShipSwift video walkthrough released on 2026-05-12.

Single iOS app, dual roles (customer / shop owner), 14 production-grade SwiftUI components pulled directly from ShipSwift recipes. Zero third-party dependencies, local SwiftData only — no backend, no API keys, clone & run.

---

## Project Info

| Field | Value |
|---|---|
| Bundle ID | `com.signerlabs.BobaLoyalty` |
| Team ID | `5GS4D3667R` |
| iOS Deployment Target | 26.4 |
| Swift | 5.0 (MainActor isolation by default) |
| Xcode project layout | `PBXFileSystemSynchronizedRootGroup` — new `.swift` files auto-sync into the build target, **no need to touch `project.pbxproj`** |
| Backend | None (pure local SwiftData mock, no AWS) |
| Third-party deps | None (zero SPM / CocoaPods) |

---

## Dual-Role Architecture

Single app with a startup role selector (persisted in `@AppStorage`):

```
RootRouterView (App/)
├─ unset      → RoleSelectView      (App/RoleSelectView.swift)
├─ customer   → CustomerRootTabView (Customer/)
│                ├─ Menu     MenuView         (Menu/)
│                ├─ Cart     CartView         (Cart/)
│                ├─ Points   PointsView       (Points/)
│                └─ Profile  ProfileView      (Profile/)
└─ owner      → OwnerRootTabView    (Owner/)
                 ├─ Orders   OrdersBoardView      (Orders/)
                 ├─ Menu     MenuAdminView        (Menu/)
                 ├─ Revenue  RevenueDashboardView (Revenue/)
                 └─ Settings OwnerSettingsView    (Settings/)
```

Tap "Switch Role" inside either side's settings to reset `@AppStorage` and return to the selector.

---

## ShipSwift Recipes Used (14)

All recipe source code is dropped verbatim into `BobaLoyalty/SWPackage/` with the `SW` filename prefix so it's instantly recognizable as "this part came from ShipSwift" when watching the video.

| Recipe ID | File | Used For |
|---|---|---|
| `component-alert` | `SWAlert.swift` | Global toast — added to cart, payment success, role switched, etc. |
| `component-root-tab-view` | `SWRootTabView.swift` | Dual-side `TabView` template (iOS 18 Tab API + selection state + sensoryFeedback) |
| `component-tab-button` | `SWTabButton.swift` | Menu category chips |
| `component-order-view` | `SWOrderView.swift` + `SWOrderSelector.swift` + `SWQuantityControl.swift` | **Product detail core** — `matchedGeometryEffect` three-cup animation + sugar/size selection + quantity controls |
| `component-stepper` | `SWStepper.swift` | Cart row quantity ± |
| `component-loading` | `SWLoading.swift` | Mock 1-second full-screen payment overlay |
| `component-search-bar` | `SWSearchBar.swift` | Owner-side menu admin search |
| `component-add-sheet` | `SWAddSheet.swift` | Owner-side broadcast coupon amount sheet |
| `chart-ring-chart` | `SWRingChart.swift` | Customer points center — concentric dual rings (distance to free / monthly cups) |
| `chart-bar-chart` | `SWBarChart.swift` | Owner revenue — daily revenue bar chart, last 7 days |
| `chart-line-chart` | `SWLineChart.swift` | Owner revenue — 30-day order trend line + daily average reference |
| `chart-donut-chart` | `SWDonutChart.swift` | Owner revenue — product sales share donut |

**Consistent recipe IDs across the stack**: pull a recipe via `mcp__shipswift__getRecipe` + ID. The video shows the full `getRecipe id=component-order-view → copy source → use it` flow live.

---

## Visual System

### Brand Palette (`Assets.xcassets/Colors/`)

| Color Set | Usage |
|---|---|
| `BobaCream` (warm cream) | Customer-side background |
| `BobaCaramel` (caramel) | Primary (AccentColor) |
| `BobaBrown` (milk-tea brown) | Primary text / titles |
| `BobaPearl` (pearl white) | Soft ivory backdrop |
| `BobaMatcha` (matcha green) | Points ring inner |
| `BobaPink` (strawberry pink) | "Hot" badge |

### Product Images (`Assets.xcassets/Drinks/`)

8 photos from [Unsplash](https://unsplash.com) — CC0, no attribution required (acknowledgements below).

| Product | imageName | Unsplash photo ID |
|---|---|---|
| Signature Milk Tea | `Drink_NaiCha` | `1741244133076-afcdda4befae` (Gong Cha black sugar pearl) |
| Pearl Milk Tea | `Drink_ZhenZhu` | `1741243038487-1d835e67bcbf` (Tiger Sugar lineup) |
| Matcha Latte | `Drink_MoCha` | `1717398804885-a6c22b3e5c2f` |
| Jasmine Green Milk | `Drink_MoLi` | `1631308491952-040f80133535` |
| Taro Ball Milk Tea | `Drink_YuYuan` | `1743310835057-560495386d45` |
| Roasted Milk | `Drink_KaoNai` | `1756132539966-8d65f7a9eed8` (Caramel) |
| Mango Pomelo Sago | `Drink_YangZhi` | `1604298331663-de303fbc7059` |
| Lemon Fruit Tea | `Drink_NingMeng` | `1596343540266-130b3dbb1158` |

Same-named ColorSets under `DrinkColors/` serve as fallback tints before images load, and as the gradient base color on detail pages.

---

## Getting Started

```bash
git clone https://github.com/signerlabs/bobaloyalty-ios.git
cd bobaloyalty-ios
open BobaLoyalty.xcodeproj
```

In Xcode:

1. Select iPhone 17 Pro Simulator (or any iOS 26.4+ device)
2. `Cmd+R` to run
3. On first launch the app auto-seeds mock data: 30 days of order history, 8 products, 1 anonymous member
4. Owner-side Orders tab injects 4 active orders on first entry (`OwnerActiveOrderSeed`), so visit Orders before other tabs for the best demo flow

No API keys required. No accounts. Pure local SwiftData mock.

---

## Video Demo Order

The video walkthrough roughly follows this path:

1. **Role selector** (warm-gradient opener) → tap "I'm a customer"
2. **Menu** (real boba photos + "Hot" badge)
3. **Product detail** (**core wow-moment**: sugar/size selection → quantity 1→2→3 spring animation + `matchedGeometryEffect` cup reshuffle)
4. **Add to cart → cart list → checkout**
5. **Mock payment** (WeChat / Alipay → `SWLoading` 1s → success toast)
6. **Points center** (1.2s ease-out ring animation → redeem free cup at 100)
7. **Birthday coupon** (set birthday within 7 days → auto-redeemed)
8. **Settings → Switch role → enter owner side**
9. **Order board** (live orders + status badge transitions)
10. **Menu admin** (search / edit / archive)
11. **Revenue dashboard** (**core wow-moment**: 3 Swift Charts animate in sequence → tap donut slice to switch center number)
12. **Settings → Broadcast birthday coupon** (enter amount → all members receive one)

---

## File Structure

```
BobaLoyalty/
├── BobaLoyaltyApp.swift                  # @main + ModelContainer + .swAlert() + MockSeed
├── App/
│   ├── RootRouterView.swift              # @AppStorage routing
│   └── RoleSelectView.swift              # Role selector (warm gradient + two buttons)
├── Customer/                             # Customer side
│   ├── CustomerRootTabView.swift         # 4-tab container
│   ├── Components/DrinkThumbnail.swift   # Reusable drink thumbnail (Image + ColorSet fallback)
│   ├── Menu/{MenuView, ProductDetailView}.swift
│   ├── Cart/{CartView, CheckoutView}.swift
│   ├── Points/PointsView.swift
│   └── Profile/ProfileView.swift
├── Owner/                                # Owner side
│   ├── OwnerRootTabView.swift            # 4-tab container
│   ├── Orders/{OrdersBoardView, OrderRowCard, OrderStatusBadge, OrderDetailView, OwnerActiveOrderSeed}.swift
│   ├── Menu/{MenuAdminView, ProductEditView}.swift
│   ├── Revenue/RevenueDashboardView.swift
│   └── Settings/OwnerSettingsView.swift
├── Models/                               # SwiftData @Model
│   ├── {Product, CartItem, Order, Customer, Coupon}.swift
│   └── MockSeed.swift                    # 8 products + 1 member + 30 days of orders
├── Shared/
│   ├── UserRole.swift                    # enum + AppStorageKey
│   └── Date+RelativeTime.swift           # Relative time formatter
├── SWPackage/                            # 14 ShipSwift recipes, verbatim
│   └── SW*.swift
└── Assets.xcassets/
    ├── Colors/Boba*.colorset             # 6 brand colors
    ├── DrinkColors/Drink_*.colorset      # 8 fallback drink colors
    └── Drinks/Drink_*.imageset           # 8 Unsplash boba photos
```

---

## Engineering Constraints

- **No `xcodebuild`** — build via Xcode / Simulator
- **No `pbxproj` edits** — `PBXFileSystemSynchronizedRootGroup` auto-syncs the entire `BobaLoyalty/` directory
- **No third-party dependencies** — zero SPM / CocoaPods is a design goal
- **Every file using SwiftData APIs must `import SwiftData`** at the top — easy to forget, breaks the build
- **SourceKit "Cannot find X in scope" warnings are often false positives** after bulk file additions — index lags, real compilation passes
- **Demo order constraint**: owner-side Orders tab injects active orders only on first entry (`OwnerActiveOrderSeed`). Visit Orders before other tabs for the demo.

---

## Built with Claude Code + ShipSwift

This entire app was vibe-coded in a single afternoon using [Claude Code](https://claude.com/claude-code) + ShipSwift recipes — no manual UI code from scratch. The 14 recipes above were dropped in verbatim via the ShipSwift MCP server, and the surrounding business logic was generated through natural-language collaboration with the model.

If you want to learn the workflow:

- ShipSwift main repo: [signerlabs/ShipSwift](https://github.com/signerlabs/ShipSwift)
- Try a recipe yourself: `mcp__shipswift__searchRecipes` or browse the recipe gallery

---

## Acknowledgements

Product images are from [Unsplash](https://unsplash.com), CC0 (no attribution required). Photographer credits available on each photo's `unsplash.com/photos/{id}` page.

---

## License

MIT — see [LICENSE](LICENSE).
