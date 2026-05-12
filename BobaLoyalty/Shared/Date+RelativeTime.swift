//
//  Date+RelativeTime.swift
//  BobaLoyalty
//
//  Date extension that formats Chinese relative-time strings, used by order cards
//  to display values like "3 minutes ago / 1 hour ago / yesterday" in Chinese.
//  Shared by both the customer and owner sides.
//

import Foundation

extension Date {
    /// Chinese relative-time description
    /// - within 60 seconds: 刚刚 (just now)
    /// - within 1 hour:     x 分钟前 (x minutes ago)
    /// - within 24 hours:   x 小时前 (x hours ago)
    /// - within same year:  x月x日 (M月d日)
    /// - across years:      yyyy年x月x日
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
