//
//  Coupon.swift
//  BobaLoyalty
//
//  优惠券模型：生日券 / 老板群发促销券
//  kindRaw 用 String 持久化，方便后期扩展更多券类
//

import Foundation
import SwiftData

// MARK: - 券种

enum CouponKind: String, Codable, CaseIterable {
    case birthday   // 生日券（系统自动派发）
    case promo      // 促销券（老板群发）

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
    /// 券种
    var kindRaw: String
    /// 标题（如"生日特饮免费券"）
    var title: String
    /// 优惠值（满减金额或固定折扣）
    var discountValue: Double
    /// 过期时间
    var expiresAt: Date
    /// 是否已核销
    var isRedeemed: Bool
    /// 持有者 ID
    var customerID: String
    /// 核销时间（未核销则为 nil）
    var redeemedAt: Date?
    /// 派发时间
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

    /// 类型安全的券种访问器
    var kind: CouponKind {
        get { CouponKind(rawValue: kindRaw) ?? .promo }
        set { kindRaw = newValue.rawValue }
    }

    /// 是否已过期
    var isExpired: Bool {
        Date.now > expiresAt
    }

    /// 是否可用（未核销 + 未过期）
    var isUsable: Bool {
        !isRedeemed && !isExpired
    }
}
