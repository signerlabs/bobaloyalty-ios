//
//  CartItem.swift
//  BobaLoyalty
//
//  购物车项：用户选好的某款商品 + 规格 + 数量
//  与 Product 是多对一引用关系；下单后转为 OrderLine 嵌入 Order。
//

import Foundation
import SwiftData

@Model
final class CartItem {
    @Attribute(.unique) var id: UUID
    /// 引用商品；用 Optional 防止商品被删后购物车整体崩溃
    var product: Product?
    /// 已选规格（中杯 / 大杯）
    var size: String
    /// 已选糖度（无糖 / 三分糖等）
    var sugar: String
    /// 加料（珍珠 / 椰果 / 布丁），可为空
    var addons: [String]
    /// 数量
    var quantity: Int
    /// 该规格的单价（避免后续商品涨价，购物车里看到的价就是下单价）
    var unitPrice: Double
    /// 加入购物车时间
    var addedAt: Date

    init(
        id: UUID = UUID(),
        product: Product?,
        size: String,
        sugar: String,
        addons: [String] = [],
        quantity: Int = 1,
        unitPrice: Double,
        addedAt: Date = .now
    ) {
        self.id = id
        self.product = product
        self.size = size
        self.sugar = sugar
        self.addons = addons
        self.quantity = quantity
        self.unitPrice = unitPrice
        self.addedAt = addedAt
    }

    /// 该项小计
    var lineTotal: Double {
        unitPrice * Double(quantity)
    }
}
