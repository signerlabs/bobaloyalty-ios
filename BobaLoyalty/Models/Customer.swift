//
//  Customer.swift
//  BobaLoyalty
//
//  会员模型：扫码即开卡，匿名优先（不强制留手机号）
//  totalPoints 由订单事件累加，老板端可看会员总览
//

import Foundation
import SwiftData

@Model
final class Customer {
    @Attribute(.unique) var id: UUID
    /// 昵称（匿名时显示"奶茶达人 #1234"）
    var nickname: String
    /// 手机号（可选，留空表示匿名会员）
    var phone: String?
    /// 生日（用于自动派发生日券）
    var birthday: Date?
    /// 累计积分
    var totalPoints: Int
    /// 加入时间
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

    /// 距离下一杯免费还差多少分（满 100 换一杯）
    var pointsToNextReward: Int {
        max(0, 100 - (totalPoints % 100))
    }
}
