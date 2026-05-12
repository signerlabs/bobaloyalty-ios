//
//  MockSeed.swift
//  BobaLoyalty
//
//  Local mock data seed: 8 products + 1 anonymous member + 30 days of historical orders.
//  Auto-seeds on launch when the store is empty; later launches skip seeding.
//

import Foundation
import SwiftData

@MainActor
enum MockSeed {

    /// Main entry point: seeds data when the store is empty
    static func seedIfNeeded(in context: ModelContext) {
        do {
            let productCount = try context.fetchCount(FetchDescriptor<Product>())
            guard productCount == 0 else { return }

            // 1. Products
            let products = seedProducts()
            for p in products { context.insert(p) }

            // 2. Anonymous member
            let customer = seedCustomer()
            context.insert(customer)

            // 3. 30 days of historical orders (so the revenue dashboard and purchase history have data)
            let orders = seedHistoricalOrders(products: products, customer: customer)
            for o in orders { context.insert(o) }

            // 4. Accumulate earned points on the member
            customer.totalPoints = orders.reduce(0) { $0 + $1.pointsEarned }

            // 5. One unredeemed promo coupon
            let promo = Coupon(
                kind: .promo,
                title: "招牌奶茶 -5 元",
                discountValue: 5.0,
                expiresAt: Calendar.current.date(byAdding: .day, value: 14, to: .now) ?? .now,
                customerID: customer.id.uuidString
            )
            context.insert(promo)

            try context.save()
        } catch {
            print("[MockSeed] Failed to write seed data: \(error)")
        }
    }

    // MARK: - Products

    private static func seedProducts() -> [Product] {
        [
            Product(
                name: "招牌奶茶",
                categoryName: "招牌",
                price: 16,
                imageName: "Drink_NaiCha",
                isOnSale: true
            ),
            Product(
                name: "珍珠奶茶",
                categoryName: "奶茶系列",
                price: 14,
                imageName: "Drink_ZhenZhu",
                isOnSale: true
            ),
            Product(
                name: "抹茶拿铁",
                categoryName: "奶茶系列",
                price: 18,
                imageName: "Drink_MoCha"
            ),
            Product(
                name: "茉莉奶绿",
                categoryName: "奶茶系列",
                price: 15,
                imageName: "Drink_MoLi"
            ),
            Product(
                name: "芋圆奶茶",
                categoryName: "奶茶系列",
                price: 19,
                imageName: "Drink_YuYuan"
            ),
            Product(
                name: "烤奶",
                categoryName: "奶茶系列",
                price: 17,
                imageName: "Drink_KaoNai"
            ),
            Product(
                name: "杨枝甘露",
                categoryName: "果茶系列",
                price: 22,
                imageName: "Drink_YangZhi",
                isOnSale: true
            ),
            Product(
                name: "柠檬果茶",
                categoryName: "果茶系列",
                price: 16,
                imageName: "Drink_NingMeng"
            )
        ]
    }

    // MARK: - Anonymous member

    private static func seedCustomer() -> Customer {
        let nickname = "奶茶达人 #\(Int.random(in: 1000...9999))"
        return Customer(
            nickname: nickname,
            totalPoints: 0,
            joinedAt: Calendar.current.date(byAdding: .day, value: -30, to: .now) ?? .now
        )
    }

    // MARK: - Historical orders (random ~24 orders across the last 30 days)

    private static func seedHistoricalOrders(
        products: [Product],
        customer: Customer
    ) -> [Order] {
        let calendar = Calendar.current
        let addonChoices = ["珍珠", "椰果", "布丁", "芋圆", "燕麦"]
        var orders: [Order] = []

        for dayOffset in 0..<30 {
            // 0~2 orders per day to simulate "busy days vs. slow days"
            let dailyOrderCount = Int.random(in: 0...2)
            for _ in 0..<dailyOrderCount {
                let baseDate = calendar.date(byAdding: .day, value: -dayOffset, to: .now) ?? .now
                let hour = Int.random(in: 10...20)
                let minute = Int.random(in: 0...59)
                let createdAt = calendar.date(
                    bySettingHour: hour,
                    minute: minute,
                    second: 0,
                    of: baseDate
                ) ?? baseDate

                // 1~3 cups
                let cupCount = Int.random(in: 1...3)
                var lines: [OrderLine] = []
                for _ in 0..<cupCount {
                    guard let p = products.randomElement() else { continue }
                    let size = p.availableSizes.randomElement() ?? "中杯"
                    let sugar = p.availableSugar.randomElement() ?? "五分糖"
                    let unitPrice = size == "大杯" ? p.price + 3 : p.price
                    let addons = Bool.random()
                        ? [addonChoices.randomElement() ?? "珍珠"]
                        : []
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
                let order = Order(
                    createdAt: createdAt,
                    items: lines,
                    totalAmount: total,
                    status: .completed,
                    pointsEarned: points,
                    customerID: customer.id.uuidString
                )
                orders.append(order)
            }
        }
        return orders
    }
}
