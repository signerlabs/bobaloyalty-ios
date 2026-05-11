//
//  Date+RelativeTime.swift
//  BobaLoyalty
//
//  Date 中文相对时间扩展：用于订单卡片显示"3 分钟前 / 1 小时前 / 昨天"等。
//  共用于顾客端和老板端。
//

import Foundation

extension Date {
    /// 中文相对时间描述
    /// - 60 秒内：刚刚
    /// - 1 小时内：x 分钟前
    /// - 24 小时内：x 小时前
    /// - 同一年内：x 月 x 日
    /// - 跨年：YYYY 年 x 月 x 日
    var relativeChinese: String {
        let now = Date()
        let interval = now.timeIntervalSince(self)

        if interval < 60 {
            return "刚刚"
        }
        if interval < 3600 {
            return "\(Int(interval / 60)) 分钟前"
        }
        if interval < 86400 {
            return "\(Int(interval / 3600)) 小时前"
        }

        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")

        if calendar.isDateInYesterday(self) {
            formatter.dateFormat = "昨天 HH:mm"
            return formatter.string(from: self)
        }

        if calendar.component(.year, from: self) == calendar.component(.year, from: now) {
            formatter.dateFormat = "M月d日 HH:mm"
        } else {
            formatter.dateFormat = "yyyy年M月d日"
        }
        return formatter.string(from: self)
    }
}
