//
//  CustomerRootTabView.swift
//  BobaLoyalty
//
//  Customer-side root TabView: Menu / Cart / Points / Profile.
//  All four tabs are wired up to real pages (tasks #4 #5 #6 took over once complete).
//
//  Follows the ShipSwift Recipe `component-root-tab-view` pattern:
//  - iOS 18+ Tab API
//  - Selected / unselected SF Symbol swapping
//  - `.environment(\.symbolVariants, .none)` prevents the system from auto-filling icons
//  - `.sensoryFeedback` provides haptic feedback
//

import SwiftUI
import SwiftData

struct CustomerRootTabView: View {
    @State private var selectedTab = "menu"

    var body: some View {
        TabView(selection: $selectedTab) {
            // MARK: Menu
            Tab(value: "menu") {
                NavigationStack { MenuView() }
            } label: {
                Label {
                    Text("菜单")
                } icon: {
                    Image(systemName: selectedTab == "menu" ? "cup.and.saucer.fill" : "cup.and.saucer")
                }
                .environment(\.symbolVariants, .none)
            }

            // MARK: Cart
            Tab(value: "cart") {
                NavigationStack { CartView() }
            } label: {
                Label {
                    Text("购物车")
                } icon: {
                    Image(systemName: selectedTab == "cart" ? "bag.fill" : "bag")
                }
                .environment(\.symbolVariants, .none)
            }

            // MARK: Points
            Tab(value: "points") {
                NavigationStack { PointsView() }
            } label: {
                Label {
                    Text("积分")
                } icon: {
                    Image(systemName: selectedTab == "points" ? "star.circle.fill" : "star.circle")
                }
                .environment(\.symbolVariants, .none)
            }

            // MARK: Profile
            Tab(value: "profile") {
                NavigationStack { ProfileView() }
            } label: {
                Label {
                    Text("我的")
                } icon: {
                    Image(systemName: selectedTab == "profile" ? "person.crop.circle.fill" : "person.crop.circle")
                }
                .environment(\.symbolVariants, .none)
            }
        }
        .tint(Color("BobaCaramel"))
        .sensoryFeedback(.increase, trigger: selectedTab)
    }
}

#Preview {
    CustomerRootTabView()
        .modelContainer(for: [
            Product.self, CartItem.self, Order.self, Customer.self, Coupon.self
        ], inMemory: true)
}
