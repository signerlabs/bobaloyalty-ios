//
//  Date+RelativeTime.swift
//  BobaLoyalty
//
//  Date extension that formats English relative-time strings, used by order cards
//  to display values like "Just now / 3 min ago / 1 h ago / Yesterday".
//  Shared by both the customer and owner sides.
//

import Foundation

extension Date {
    /// English relative-time description
    /// - within 60 seconds: Just now
    /// - within 1 hour:     x min ago
    /// - within 24 hours:   x h ago
    /// - yesterday:         Yesterday HH:mm
    /// - within same year:  MMM d HH:mm
    /// - across years:      MMM d, yyyy
    var relativeChinese: String {
        let now = Date()
        let interval = now.timeIntervalSince(self)

        if interval < 60 {
            return "Just now"
        }
        if interval < 3600 {
            return "\(Int(interval / 60)) min ago"
        }
        if interval < 86400 {
            return "\(Int(interval / 3600)) h ago"
        }

        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")

        if calendar.isDateInYesterday(self) {
            formatter.dateFormat = "'Yesterday' HH:mm"
            return formatter.string(from: self)
        }

        if calendar.component(.year, from: self) == calendar.component(.year, from: now) {
            formatter.dateFormat = "MMM d HH:mm"
        } else {
            formatter.dateFormat = "MMM d, yyyy"
        }
        return formatter.string(from: self)
    }
}
