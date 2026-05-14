//
//  Customer.swift
//  BobaLoyalty
//
//  Member model: scan to enroll, anonymous-first (no phone number required).
//  `totalPoints` accumulates from order events; the owner side can view a member overview.
//

import Foundation
import SwiftData

@Model
final class Customer {
    @Attribute(.unique) var id: UUID
    /// Nickname (anonymous members display as "Boba Fan #1234")
    var nickname: String
    /// Phone number (optional, nil means anonymous member)
    var phone: String?
    /// Birthday (used to auto-issue birthday coupons)
    var birthday: Date?
    /// Lifetime points balance
    var totalPoints: Int
    /// Join date
    var joinedAt: Date

    init(
        id: UUID = UUID(),
        nickname: String,
        phone: String? = nil,
        birthday: Date? = nil,
        totalPoints: Int = 0,
        joinedAt: Date = .now
    ) {
        self.id = id
        self.nickname = nickname
        self.phone = phone
        self.birthday = birthday
        self.totalPoints = totalPoints
        self.joinedAt = joinedAt
    }

    /// Points still needed for the next free drink (every 100 points redeems one)
    var pointsToNextReward: Int {
        max(0, 100 - (totalPoints % 100))
    }
}
