//
//  RootRouterView.swift
//  BobaLoyalty
//
//  Root router: picks which root view to show based on @AppStorage("userRole").
//  - unset    → RoleSelectView (role selector)
//  - customer → CustomerRootTabView (customer-side 4-tab)
//  - owner    → OwnerRootTabView (owner-side 4-tab)
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
