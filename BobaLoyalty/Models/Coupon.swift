//
//  Coupon.swift
//  BobaLoyalty
//
//  Coupon model: birthday coupon / owner-broadcast promo coupon.
//  `kindRaw` is persisted as a String so more coupon kinds can be added later.
//

import Foundation
import SwiftData

// MARK: - Coupon kind

enum CouponKind: String, Codable, CaseIterable {
    case birthday   // Birthday coupon (auto-issued by the system)
    case promo      // Promo coupon (broadcast by the owner)

    var displayName: String {
        switch self {
        case .birthday: "生日券"
        case .promo:    "促销券"
        }
    }

    var iconName: String {
        switch self {
        case .birthday: "gift.fill"
        case .promo:    "ticket.fill"
        }
    }
}

// MARK: - Coupon

@Model
final class Coupon {
    @Attribute(.unique) var id: UUID
    /// Coupon kind
    var kindRaw: String
    /// Title (e.g. "Free birthday signature drink")
    var title: String
    /// Discount value (threshold-discount amount or fixed amount off)
    var discountValue: Double
    /// Expiration time
    var expiresAt: Date
    /// Whether it has been redeemed
    var isRedeemed: Bool
    /// Holder ID
    var customerID: String
    /// Redemption time (nil if not yet redeemed)
    var redeemedAt: Date?
    /// Issuance time
    var issuedAt: Date

    init(
        id: UUID = UUID(),
        kind: CouponKind,
        title: String,
        discountValue: Double,
        expiresAt: Date,
        isRedeemed: Bool = false,
        customerID: String,
        redeemedAt: Date? = nil,
        issuedAt: Date = .now
    ) {
        self.id = id
        self.kindRaw = kind.rawValue
        self.title = title
        self.discountValue = discountValue
        self.expiresAt = expiresAt
        self.isRedeemed = isRedeemed
        self.customerID = customerID
        self.redeemedAt = redeemedAt
        self.issuedAt = issuedAt
    }

    /// Type-safe accessor for the coupon kind
    var kind: CouponKind {
        get { CouponKind(rawValue: kindRaw) ?? .promo }
        set { kindRaw = newValue.rawValue }
    }

    /// Whether the coupon has expired
    var isExpired: Bool {
        Date.now > expiresAt
    }

    /// Whether the coupon is usable (not redeemed AND not expired)
    var isUsable: Bool {
        !isRedeemed && !isExpired
    }
}
