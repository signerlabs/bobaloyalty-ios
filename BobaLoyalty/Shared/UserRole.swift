//
//  UserRole.swift
//  BobaLoyalty
//
//  双端角色枚举 + @AppStorage 字段名常量
//  通过 @AppStorage("userRole") 持久化用户当前选择的角色
//

import Foundation

enum UserRole: String, CaseIterable {
    /// 未选择（首次进入显示角色选择器）
    case unset    = ""
    /// 顾客端
    case customer = "customer"
    /// 老板端
    case owner    = "owner"
}

/// @AppStorage 字段名（统一常量，避免散落各处的字符串字面量）
enum AppStorageKey {
    static let userRole = "userRole"
}
