//
//  Product.swift
//  BobaLoyalty
//
//  Product model: milk teas, fruit teas, milk greens, and other drinks.
//  `imageName` points to a placeholder Color Set in Assets (e.g. Drink_NaiCha).
//  Later it can be swapped for real Unsplash photos or AI imagery without changing the model.
//

import Foundation
import SwiftData

@Model
final class Product {
    /// Unique product ID
    @Attribute(.unique) var id: UUID
    /// Product name (signature milk tea, boba milk tea, etc.)
    var name: String
    /// Category name (signature, milk-tea series, fruit-tea series, etc.)
    var categoryName: String
    /// Unit price for the smallest size, in CNY (yuan)
    var price: Double
    /// Placeholder Color Set name (e.g. "Drink_NaiCha"); swap the string when real photos are available
    var imageName: String
    /// Available sizes (e.g. medium / large)
    var availableSizes: [String]
    /// Available sugar levels (zero / 30% / 50% / 70% / full sugar)
    var availableSugar: [String]
    /// Whether this is a current bestseller; surfaced with a "hot" badge at the top of the menu
    var isOnSale: Bool
    /// Created-at timestamp, used to sort the owner-side product list
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
