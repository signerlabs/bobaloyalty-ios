# CLAUDE.md

Bubble tea shop loyalty app, source material for the [ShipSwift](https://github.com/signerlabs/ShipSwift) video walkthrough released on 2026-05-12.

## Read First

- [PRD.md](PRD.md) — Scope and requirements (dual-side architecture, 6 core modules, video script guidance)
- [README.md](README.md) — Project info, ShipSwift recipe inventory (14 recipes), file layout, demo recording notes, known pitfalls

## Engineering Constraints

- **No `xcodebuild`** — build via Xcode / Simulator
- **No `pbxproj` edits** — `PBXFileSystemSynchronizedRootGroup` auto-syncs every `.swift` file under `BobaLoyalty/`
- **No third-party dependencies** — zero SPM / CocoaPods is a design goal
- **Every file using SwiftData APIs must `import SwiftData`** at the top — easy to miss, breaks the build
- **SourceKit "Cannot find X in scope" warnings are often false positives** after bulk file additions — index lags, real compilation passes
- **iOS 26.4 / Swift 5 / MainActor isolation by default**

## ShipSwift Recipe Integration

Pull recipes via `mcp__shipswift__getRecipe id=<recipe-id>` and drop the source verbatim into `SWPackage/SW*.swift`. File names map 1:1 to recipe IDs so the video can show the "pull recipe → copy → use" flow directly. 14 recipes are integrated — see the [README](README.md#shipswift-recipes-used-14) for the full table.
