//
//  RootRouterView.swift
//  BobaLoyalty
//
//  根路由：根据 @AppStorage("userRole") 决定显示哪个根视图
//  - 未选择 → RoleSelectView（角色选择器）
//  - customer → CustomerRootTabView（顾客端 4-Tab）
//  - owner → OwnerRootTabView（老板端 4-Tab）
//

import SwiftUI
import SwiftData

struct RootRouterView: View {
    @AppStorage(AppStorageKey.userRole) private var userRoleRaw: String = UserRole.unset.rawValue

    private var role: UserRole {
        UserRole(rawValue: userRoleRaw) ?? .unset
    }

    var body: some View {
        switch role {
        case .unset:
            RoleSelectView()
                .transition(.opacity.combined(with: .scale(scale: 0.98)))
        case .customer:
            CustomerRootTabView()
                .transition(.opacity)
        case .owner:
            OwnerRootTabView()
                .transition(.opacity)
        }
    }
}

#Preview("Role Select") {
    RootRouterView()
        .modelContainer(for: [
            Product.self, CartItem.self, Order.self, Customer.self, Coupon.self
        ], inMemory: true)
}
