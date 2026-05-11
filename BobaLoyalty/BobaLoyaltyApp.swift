//
//  BobaLoyaltyApp.swift
//  BobaLoyalty
//
//  App 入口：
//  - 注入 SwiftData modelContainer（5 个 @Model：Product / CartItem / Order / Customer / Coupon）
//  - 启动时 MockSeed 检测空库自动灌入种子数据（8 商品 + 1 会员 + 30 天历史订单）
//  - 在根视图挂 .swAlert() 启用全局 toast（ShipSwift Recipe: component-alert）
//  - RootRouterView 根据 @AppStorage("userRole") 路由到角色选择 / 顾客端 / 老板端
//

import SwiftUI
import SwiftData

@main
struct BobaLoyaltyApp: App {

    /// 共享的 SwiftData 容器，App 生命周期内单例
    let modelContainer: ModelContainer

    init() {
        do {
            let schema = Schema([
                Product.self,
                CartItem.self,
                Order.self,
                Customer.self,
                Coupon.self
            ])
            let config = ModelConfiguration(schema: schema)
            modelContainer = try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("[BobaLoyaltyApp] 无法创建 ModelContainer：\(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            RootRouterView()
                .swAlert()
                .task {
                    // 主线程上下文（@MainActor 保证）
                    MockSeed.seedIfNeeded(in: modelContainer.mainContext)
                }
        }
        .modelContainer(modelContainer)
    }
}
