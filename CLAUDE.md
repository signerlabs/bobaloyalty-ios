# CLAUDE.md

奶茶店点单 App，**2026-05-12 ShipSwift 视频录屏素材源**。

## 必读

- [PRD.md](PRD.md) — 需求与范围（双端架构、6 个核心模块、视频脚本指引）
- [README.md](README.md) — 工程信息、14 个 ShipSwift Recipe 引用清单、文件结构、录屏指引、已知陷阱

## 关键约束（不要再问）

- **不跑 `xcodebuild`**——主公在 Xcode/Simulator 测试
- **不改 pbxproj**——`PBXFileSystemSynchronizedRootGroup` 自动同步 `BobaLoyalty/` 下所有 .swift
- **不 git commit/push**——主公自己提交
- **不引入第三方依赖**——零 SPM 是设计目标
- **每个用 SwiftData API 的文件顶部 `import SwiftData`**——早期漏过 3 处导致编译失败
- **SourceKit「Cannot find X in scope」是误报**——索引追不上，真编译会过
- **iOS 26.4 / Swift 5 / MainActor 默认隔离**

## ShipSwift Recipe 集成方式

通过 `mcp__shipswift__getRecipe id=<recipe-id>` 拉源码，原样放 `SWPackage/SW*.swift`。组件 ID 与 SW 文件名一一对应，便于视频里现场展示「拉 Recipe → 复制 → 用上」全流程。当前已集成 14 个，详细映射见 [README.md](README.md#shipswift-recipe-引用清单14-个)。
