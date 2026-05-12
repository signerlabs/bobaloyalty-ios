//
//  Order.swift
//  BobaLoyalty
//
//  Order model: one checkout = one Order.
//  OrderLine is stored as a Codable struct rather than a nested SwiftData relationship,
//  which both avoids relationship-graph complexity and prevents historical orders from
//  losing data if a product is later deleted or renamed.
//

import Foundation
import SwiftData

// MARK: - Order status

enum OrderStatus: String, Codable, CaseIterable {
    case pending      // Awaiting preparation
    case making       // In preparation
    case ready        // Ready for pickup
    case completed    // Completed
    case cancelled    // Cancelled

    var displayName: String {
        switch self {
        case .pending:   "待制作"
        case .making:    "制作中"
        case .ready:     "待自取"
        case .completed: "已完成"
        case .cancelled: "已取消"
        }
    }
}

// MARK: - Order line (embedded in Order, not part of the relationship graph)

struct OrderLine: Codable, Hashable, Identifiable {
    var id: UUID
    var productName: String
    var size: String
    var sugar: String
    var addons: [String]
    var quantity: Int
    var unitPrice: Double
    /// Placeholder color name, so order details can still render a color swatch for the product
    var imageName: String

    init(
        id: UUID = UUID(),
        productName: String,
        size: String,
        sugar: String,
        addons: [String] = [],
        quantity: Int,
        unitPrice: Double,
        imageName: String
    ) {
        self.id = id
        self.productName = productName
        self.size = size
        self.sugar = sugar
        self.addons = addons
        self.quantity = quantity
        self.unitPrice = unitPrice
        self.imageName = imageName
    }

    var lineTotal: Double {
        unitPrice * Double(quantity)
    }
}

// MARK: - Order

@Model
final class Order {
    @Attribute(.unique) var id: UUID
    var createdAt: Date
    /// Line items (multiple cups)
    var items: [OrderLine]
    /// Order total amount
    var totalAmount: Double
    /// Status (persisted as rawValue, makes Predicate filtering easier)
    var statusRaw: String
    /// Points earned by this order
    var pointsEarned: Int
    /// Customer ID (UUID string for easy cross-table lookups)
    var customerID: String

    init(
        id: UUID = UUID(),
        createdAt: Date = .now,
        items: [OrderLine],
        totalAmount: Double,
        status: OrderStatus = .completed,
        pointsEarned: Int,
        customerID: String
    ) {
        self.id = id
        self.createdAt = createdAt
        self.items = items
        self.totalAmount = totalAmount
        self.statusRaw = status.rawValue
        self.pointsEarned = pointsEarned
        self.customerID = customerID
    }

    /// Type-safe accessor for the status
    var status: OrderStatus {
        get { OrderStatus(rawValue: statusRaw) ?? .pending }
        set { statusRaw = newValue.rawValue }
    }

    /// Total cup count
    var totalCups: Int {
        items.reduce(0) { $0 + $1.quantity }
    }
}
