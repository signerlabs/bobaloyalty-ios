//
//  OwnerActiveOrderSeed.swift
//  BobaLoyalty
//
//  老板端 Tab 1 专用：在没有任何"今日活跃订单"时，注入若干 pending/making/ready
//  状态订单，让视频录屏时订单流的状态切换演示更有戏。
//
//  与 MockSeed 互不干扰：MockSeed 只灌历史 30 天的 completed 订单；本文件只补
//  当天的活跃订单（不重复创建）。
//

import Foundation
import SwiftData

@MainActor
enum OwnerActiveOrderSeed {

    /// 检测今日是否有活跃订单（pending/making/ready），没有则注入演示数据
    static func seedTodayActiveOrdersIfNeeded(in context: ModelContext) {
        do {
            let products = try context.fetch(FetchDescriptor<Product>())
            guard !products.isEmpty else { return }

            let customers = try context.fetch(FetchDescriptor<Customer>())
            guard let customer = customers.first else { return }

            // 检测当天是否已有 active 订单（避免每次进 Tab 都重复灌）
            let calendar = Calendar.current
            let startOfToday = calendar.startOfDay(for: .now)
            let allOrders = try context.fetch(FetchDescriptor<Order>())
            let hasTodayActive = allOrders.contains { order in
                order.createdAt >= startOfToday
                    && (order.status == .pending || order.status == .making || order.status == .ready)
            }
            guard !hasTodayActive else { return }

            // 注入 4 张今日活跃订单：2 pending + 1 making + 1 ready
            let demoOrders = buildDemoActiveOrders(
                products: products,
                customer: customer,
                now: .now
            )
            for order in demoOrders {
                context.insert(order)
            }

            try context.save()
        } catch {
            print("[OwnerActiveOrderSeed] 注入失败：\(error)")
        }
    }

    // MARK: - 演示数据生成

    private static func buildDemoActiveOrders(
        products: [Product],
        customer: Customer,
        now: Date
    ) -> [Order] {
        let calendar = Calendar.current
        let addonChoices = ["珍珠", "椰果", "布丁", "芋圆"]

        // 4 张订单，时间从 18 分钟前 → 2 分钟前依次推进
        let recipes: [(minutesAgo: Int, status: OrderStatus, cupCount: Int)] = [
            (18, .ready, 2),
            (10, .making, 1),
            (5,  .pending, 3),
            (2,  .pending, 1)
        ]

        var orders: [Order] = []
        for (i, recipe) in recipes.enumerated() {
            let createdAt = calendar.date(byAdding: .minute, value: -recipe.minutesAgo, to: now) ?? now

            var lines: [OrderLine] = []
            for j in 0..<recipe.cupCount {
                let p = products[(i * 3 + j) % products.count]
                let size = p.availableSizes.randomElement() ?? "中杯"
                let sugar = p.availableSugar.randomElement() ?? "五分糖"
                let unitPrice = size == "大杯" ? p.price + 3 : p.price
                let addons: [String] = (j % 2 == 0) ? [addonChoices.randomElement() ?? "珍珠"] : []
                lines.append(
                    OrderLine(
                        productName: p.name,
                        size: size,
                        sugar: sugar,
                        addons: addons,
                        quantity: 1,
                        unitPrice: unitPrice,
                        imageName: p.imageName
                    )
                )
            }
            let total = lines.reduce(0.0) { $0 + $1.lineTotal }
            let points = lines.reduce(0) { $0 + $1.quantity * 10 }
            orders.append(
                Order(
                    createdAt: createdAt,
                    items: lines,
                    totalAmount: total,
                    status: recipe.status,
                    pointsEarned: points,
                    customerID: customer.id.uuidString
                )
            )
        }
        return orders
    }
}
