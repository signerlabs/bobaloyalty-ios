//
//  CartItem.swift
//  BobaLoyalty
//
//  Cart item: a product the user has selected + size/sugar/add-ons + quantity.
//  Has a many-to-one reference to Product; on checkout it is converted into an
//  OrderLine embedded in an Order.
//

import Foundation
import SwiftData

@Model
final class CartItem {
    @Attribute(.unique) var id: UUID
    /// Referenced product; Optional so the cart doesn't crash if a product is deleted
    var product: Product?
    /// Chosen size (e.g. medium / large)
    var size: String
    /// Chosen sugar level (e.g. zero / 30% / 50%)
    var sugar: String
    /// Add-ons (pearls / coconut jelly / pudding, etc.); may be empty
    var addons: [String]
    /// Quantity
    var quantity: Int
    /// Unit price for the chosen size (locked in so later price changes don't affect what was added to the cart)
    var unitPrice: Double
    /// Time added to cart
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

    /// Line subtotal
    var lineTotal: Double {
        unitPrice * Double(quantity)
    }
}
