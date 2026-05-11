//
//  Order.swift
//  BobaLoyalty
//
//  订单模型：一次下单 = 一个 Order
//  OrderLine 用 Codable struct 保存，避免 SwiftData 嵌套关系的复杂度
//  （也防止商品后期被删或改名导致历史订单数据消失）
//

import Foundation
import SwiftData

// MARK: - 订单状态

enum OrderStatus: String, Codable, CaseIterable {
    case pending      // 待制作
    case making       // 制作中
    case ready        // 待自取
    case completed    // 已完成
    case cancelled    // 已取消

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

// MARK: - 订单明细行（嵌入 Order，不参与关系图）

struct OrderLine: Codable, Hashable, Identifiable {
    var id: UUID
    var productName: String
    var size: String
    var sugar: String
    var addons: [String]
    var quantity: Int
    var unitPrice: Double
    /// 占位色，方便订单详情仍能渲染商品色卡
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
    /// 明细行（多杯）
    var items: [OrderLine]
    /// 订单总额
    var totalAmount: Double
    /// 状态（用 rawValue 持久化，方便 Predicate 过滤）
    var statusRaw: String
    /// 本单实得积分
    var pointsEarned: Int
    /// 顾客 ID（用 UUID 字符串方便跨表查询）
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

    /// 类型安全的状态访问器
    var status: OrderStatus {
        get { OrderStatus(rawValue: statusRaw) ?? .pending }
        set { statusRaw = newValue.rawValue }
    }

    /// 总杯数
    var totalCups: Int {
        items.reduce(0) { $0 + $1.quantity }
    }
}
