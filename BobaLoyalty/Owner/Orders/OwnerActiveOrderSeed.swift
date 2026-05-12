//
//  OwnerActiveOrderSeed.swift
//  BobaLoyalty
//
//  Specific to owner-side Tab 1: injects pending/making/ready orders when there
//  are no "active orders today", so the order-flow status transitions look lively
//  during demo recordings.
//
//  Independent of MockSeed: MockSeed only seeds 30 days of historical completed
//  orders; this file only fills in today's active orders (and never duplicates).
//

import Foundation
import SwiftData

@MainActor
enum OwnerActiveOrderSeed {

    /// Check whether there are any active orders today (pending/making/ready); if not, inject demo data
    static func seedTodayActiveOrdersIfNeeded(in context: ModelContext) {
        do {
            let products = try context.fetch(FetchDescriptor<Product>())
            guard !products.isEmpty else { return }

            let customers = try context.fetch(FetchDescriptor<Customer>())
            guard let customer = customers.first else { return }

            // Check whether any active order already exists today (so we don't re-seed every time the tab opens)
            let calendar = Calendar.current
            let startOfToday = calendar.startOfDay(for: .now)
            let allOrders = try context.fetch(FetchDescriptor<Order>())
            let hasTodayActive = allOrders.contains { order in
                order.createdAt >= startOfToday
                    && (order.status == .pending || order.status == .making || order.status == .ready)
            }
            guard !hasTodayActive else { return }

            // Inject 4 active orders for today: 2 pending + 1 making + 1 ready
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
            print("[OwnerActiveOrderSeed] Injection failed: \(error)")
        }
    }

    // MARK: - Demo data generation

    private static func buildDemoActiveOrders(
        products: [Product],
        customer: Customer,
        now: Date
    ) -> [Order] {
        let calendar = Calendar.current
        let addonChoices = ["珍珠", "椰果", "布丁", "芋圆"]

        // 4 orders, with timestamps progressing from 18 minutes ago → 2 minutes ago
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
