//
//  Product.swift
//  BobaLoyalty
//
//  商品模型：奶茶、果茶、奶绿等饮品
//  imageName 指向 Assets 中的占位色 Color Set（Drink_NaiCha 等），
//  后期可替换为 Unsplash 实拍 / AI 生图，不需要改模型。
//

import Foundation
import SwiftData

@Model
final class Product {
    /// 商品唯一 ID
    @Attribute(.unique) var id: UUID
    /// 商品名称（招牌奶茶、珍珠奶茶等）
    var name: String
    /// 分类名称（招牌、奶茶系列、果茶系列等）
    var categoryName: String
    /// 单价（最小规格价格，单位元）
    var price: Double
    /// 占位色 Color Set 名（如 Drink_NaiCha）；将来换实拍直接换字符串即可
    var imageName: String
    /// 可选规格（中杯 / 大杯）
    var availableSizes: [String]
    /// 可选糖度（无糖 / 三分糖 / 五分糖 / 七分糖 / 全糖）
    var availableSugar: [String]
    /// 是否是当前热卖，菜单顶部用 Badge 高亮
    var isOnSale: Bool
    /// 创建时间，用于老板端按时间排序
    var createdAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        categoryName: String,
        price: Double,
        imageName: String,
        availableSizes: [String] = ["中杯", "大杯"],
        availableSugar: [String] = ["无糖", "三分糖", "五分糖", "七分糖", "全糖"],
        isOnSale: Bool = false,
        createdAt: Date = .now
    ) {
        self.id = id
        self.name = name
        self.categoryName = categoryName
        self.price = price
        self.imageName = imageName
        self.availableSizes = availableSizes
        self.availableSugar = availableSugar
        self.isOnSale = isOnSale
        self.createdAt = createdAt
    }
}
