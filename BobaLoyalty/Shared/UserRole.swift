//
//  UserRole.swift
//  BobaLoyalty
//
//  Two-sided role enum + @AppStorage key constants.
//  The user's currently selected role is persisted via @AppStorage("userRole").
//

import Foundation

enum UserRole: String, CaseIterable {
    /// Unset (shows the role selector on first launch)
    case unset    = ""
    /// Customer side
    case customer = "customer"
    /// Owner side
    case owner    = "owner"
}

/// @AppStorage keys (centralized constants to avoid magic strings scattered across the codebase)
enum AppStorageKey {
    static let userRole = "userRole"
}
