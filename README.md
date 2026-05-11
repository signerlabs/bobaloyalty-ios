# BobaLoyalty

> 奶茶店点单 App。**2026-05-12 ShipSwift 视频录屏素材源**——展示「AI 一句话拼出 14 个生产级 SwiftUI 组件 + 一个看起来像真 App 的双端 demo」。

需求文档见 [PRD.md](PRD.md)。视频脚本：`signerlabs/1-1-signerlabs-marketing/projects/shipswift/posts/2026-05-12-视频脚本-vibecoding一个奶茶店点单App.md`。

---

## 工程信息

| 项 | 值 |
|---|---|
| Bundle ID | `com.signerlabs.BobaLoyalty` |
| Team ID | `5GS4D3667R` |
| iOS Deployment Target | 26.4 |
| Swift | 5.0（MainActor 默认隔离） |
| Xcode 工程组织 | `PBXFileSystemSynchronizedRootGroup`（新增 .swift 文件**无需改 pbxproj**，自动同步进 build target） |
| 后端 | 无（纯本地 SwiftData mock，无 AWS） |
| 第三方依赖 | 无（零 SPM/CocoaPods） |

---

## 双端架构

单 App + 启动角色选择器（@AppStorage 持久化）：

```
RootRouterView (App/)
├─ unset      → RoleSelectView   (App/RoleSelectView.swift)
├─ customer   → CustomerRootTabView   (Customer/)
│                ├─ 菜单    MenuView          (Menu/)
│                ├─ 购物车  CartView          (Cart/)
│                ├─ 积分    PointsView        (Points/)
│                └─ 我的    ProfileView       (Profile/)
└─ owner      → OwnerRootTabView      (Owner/)
                 ├─ 订单    OrdersBoardView   (Orders/)
                 ├─ 菜单    MenuAdminView     (Menu/)
                 ├─ 营收    RevenueDashboardView (Revenue/)
                 └─ 设置    OwnerSettingsView (Settings/)
```

随时通过两端"设置/我的"页的「切换角色」按钮重置 @AppStorage 回到选择器。

---

## ShipSwift Recipe 引用清单（14 个）

所有 Recipe 源码原样放在 `BobaLoyalty/SWPackage/`，文件名前缀统一 `SW`，方便录屏时一眼识别"这部分是 ShipSwift 提供的"。

| Recipe ID | 文件 | 使用位置 |
|---|---|---|
| `component-alert` | `SWAlert.swift` | 全局 toast：加购成功 / 支付成功 / 切换角色等 |
| `component-root-tab-view` | `SWRootTabView.swift` | 双端 TabView 模板（iOS 18 Tab API + 选中态 + sensoryFeedback） |
| `component-tab-button` | `SWTabButton.swift` | 菜单页分类切换 chip |
| `component-order-view` | `SWOrderView.swift` + `SWOrderSelector.swift` + `SWQuantityControl.swift` | **商品详情页核心**：matchedGeometryEffect 三杯动画 + 糖度/杯型选择 + 数量控制 |
| `component-stepper` | `SWStepper.swift` | 购物车每行数量 ± |
| `component-loading` | `SWLoading.swift` | 支付 mock 1 秒全屏遮罩 |
| `component-search-bar` | `SWSearchBar.swift` | 老板端菜单管理搜索 |
| `component-add-sheet` | `SWAddSheet.swift` | 老板端「群发券」输入金额 sheet |
| `chart-ring-chart` | `SWRingChart.swift` | 顾客端积分中心：双环嵌套（距离免费 / 本月杯数） |
| `chart-bar-chart` | `SWBarChart.swift` | 老板端营收：近 7 天每日营收柱状 |
| `chart-line-chart` | `SWLineChart.swift` | 老板端营收：近 30 天订单趋势 + 日均参考线 |
| `chart-donut-chart` | `SWDonutChart.swift` | 老板端营收：商品销量占比甜甜圈 |

**组件 ID 全链路一致**：拉 Recipe 用 `mcp__shipswift__getRecipe` + ID。视频里可现场展示「`mcp__shipswift__getRecipe id=component-order-view` → 复制源码 → 用上」的完整流程。

---

## 视觉系统

### 品牌色板（`Assets.xcassets/Colors/`）

| Color Set | 用途 |
|---|---|
| `BobaCream` 米黄 | 顾客端背景 |
| `BobaCaramel` 焦糖 | 主色（AccentColor） |
| `BobaBrown` 奶茶棕 | 主文字 / 标题 |
| `BobaPearl` 珍珠白 | 浅米奶白底 |
| `BobaMatcha` 抹茶绿 | 积分双环内圈 |
| `BobaPink` 草莓粉 | 「热卖」徽章 |

### 商品图（`Assets.xcassets/Drinks/`）

8 张 [Unsplash](https://unsplash.com) CC0 免费可商用真实奶茶照片：

| 商品 | imageName | Unsplash photo ID |
|---|---|---|
| 招牌奶茶 | `Drink_NaiCha` | `1741244133076-afcdda4befae`（Gong Cha 黑糖珍珠奶茶） |
| 珍珠奶茶 | `Drink_ZhenZhu` | `1741243038487-1d835e67bcbf`（Tiger Sugar lineup） |
| 抹茶拿铁 | `Drink_MoCha` | `1717398804885-a6c22b3e5c2f` |
| 茉莉奶绿 | `Drink_MoLi` | `1631308491952-040f80133535` |
| 芋圆奶茶 | `Drink_YuYuan` | `1743310835057-560495386d45` |
| 烤奶 | `Drink_KaoNai` | `1756132539966-8d65f7a9eed8`（焦糖浪迹） |
| 杨枝甘露 | `Drink_YangZhi` | `1604298331663-de303fbc7059` |
| 柠檬果茶 | `Drink_NingMeng` | `1596343540266-130b3dbb1158` |

`DrinkColors/` 下同名 ColorSet 共存，作为图加载前的兜底底色 + 详情页背景渐变 baseColor。

---

## 录屏指引

### 建议演示顺序

1. **角色选择器**（暖色渐变开场）→ 选「我是顾客」
2. **菜单页**（真实奶茶照片 + 热卖徽章）
3. **商品详情**（**核心炸场**：糖度/杯型选 → 数量 1→2→3 spring 动画 + matchedGeometryEffect 杯子重排）
4. **加入购物车 → 购物车列表 → 去结算**
5. **支付 mock**（微信/支付宝二选一 → SWLoading 1 秒 → 成功 toast）
6. **积分中心**（双环 1.2 秒 easeOut 动画展开 → 满 100 兑换免费一杯）
7. **生日券**（设生日近 7 天 → 自动收券）
8. **设置 → 切换角色 → 进老板端**
9. **订单流**（实时订单 + 状态徽章流转）
10. **菜单管理**（搜索 / 编辑 / 上下架）
11. **营收看板**（**核心炸场**：3 张 Swift Charts 依次入场动画 → 点甜甜圈扇区切换中心数字）
12. **设置 → 群发生日券**（输入金额 → 给所有会员各发一张）

### 视频核心炸场点（按价值排序）

1. **商品详情 matchedGeometryEffect**：三层奶茶杯 spring 弹动 + 糖度切换背景渐变
2. **营收看板 3 张图表入场动画**：1.2 秒 easeOut，柱状/折线/甜甜圈依次展开
3. **积分双环动画**：Apple Watch Activity Rings 风格
4. **支付 mock 全屏遮罩 + 1 秒 pulse**：看起来很真实
5. **菜单真奶茶照片**：第一眼就是"哎这是真 App"

### 录屏前 checklist

- [ ] 在 Xcode `Cmd+Shift+K` 清缓存 + `Cmd+B` 验证编译
- [ ] Simulator 选 iPhone 17 Pro（或主公视频常用型号）
- [ ] 状态栏时间锁定（`xcrun simctl status_bar ... override --time 9:41`）
- [ ] 关闭键盘自动弹出/通知（不要打断录屏）
- [ ] 第一次启动会自动 seed mock 数据（30 天历史订单 + 8 商品 + 1 匿名会员）
- [ ] 老板端订单 Tab 首次进入会自动注入 4 张活跃订单（OwnerActiveOrderSeed），**录屏顺序建议先 Tab 1（订单）再切其他 Tab**

---

## 文件结构

```
BobaLoyalty/
├── BobaLoyaltyApp.swift              # @main + ModelContainer + .swAlert() + MockSeed
├── App/
│   ├── RootRouterView.swift          # @AppStorage 路由
│   └── RoleSelectView.swift          # 角色选择器（暖色渐变 + 两按钮）
├── Customer/                         # 顾客端
│   ├── CustomerRootTabView.swift     # 4 tab 容器
│   ├── Components/DrinkThumbnail.swift  # 通用奶茶缩略图（Image + ColorSet 兜底）
│   ├── Menu/{MenuView, ProductDetailView}.swift
│   ├── Cart/{CartView, CheckoutView}.swift
│   ├── Points/PointsView.swift
│   └── Profile/ProfileView.swift
├── Owner/                            # 老板端
│   ├── OwnerRootTabView.swift        # 4 tab 容器
│   ├── Orders/{OrdersBoardView, OrderRowCard, OrderStatusBadge, OrderDetailView, OwnerActiveOrderSeed}.swift
│   ├── Menu/{MenuAdminView, ProductEditView}.swift
│   ├── Revenue/RevenueDashboardView.swift
│   └── Settings/OwnerSettingsView.swift
├── Models/                           # SwiftData @Model
│   ├── {Product, CartItem, Order, Customer, Coupon}.swift
│   └── MockSeed.swift                # 8 商品 + 1 会员 + 30 天订单
├── Shared/
│   ├── UserRole.swift                # enum + AppStorageKey
│   └── Date+RelativeTime.swift       # 中文相对时间
├── SWPackage/                        # 14 个 ShipSwift Recipe 原样源码
│   └── SW*.swift
└── Assets.xcassets/
    ├── Colors/Boba*.colorset         # 6 个品牌色
    ├── DrinkColors/Drink_*.colorset  # 8 个商品兜底色
    └── Drinks/Drink_*.imageset       # 8 张 Unsplash 真奶茶图
```

---

## 已知陷阱（AI 接手须知）

1. **SourceKit 误报**：批量新增 .swift 文件后，IDE 会持续报「Cannot find X in scope」一段时间。这是 `PBXFileSystemSynchronizedRootGroup` 索引追不上跨文件类型解析的已知问题——**真编译会过**，不要因此乱改代码
2. **每个用 SwiftData API 的文件必须 `import SwiftData`**（早期漏过 3 处导致主公手动报编译错才发现）
3. **不要跑 `xcodebuild`**——主公在 Xcode/Simulator 里测试
4. **不要修 pbxproj**——`PBXFileSystemSynchronizedRootGroup` 自动同步整个 `BobaLoyalty/` 目录
5. **不要 git commit/push**——主公自己提交（详见 `~/.claude/projects/-Users-m4pro-coding-signerlabs/memory/feedback_no_auto_commit.md`）
6. **不要引入第三方依赖**——零 SPM/CocoaPods 是设计目标
7. **录屏顺序约束**：老板端订单 Tab 1 首次进入才注入活跃订单（OwnerActiveOrderSeed），先看 Tab 1 再切其他

---

## 致谢

商品图来自 [Unsplash](https://unsplash.com)，CC0 免费可商用，无需 attribution。摄影师致谢见各 photo ID 对应的 `unsplash.com/photos/{id}` 页面。
