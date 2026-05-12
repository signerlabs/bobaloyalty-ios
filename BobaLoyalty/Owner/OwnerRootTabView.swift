//
//  OwnerRootTabView.swift
//  BobaLoyalty
//
//  Owner-side root TabView: Orders / Menu admin / Revenue / Settings.
//  Shares the style conventions of ShipSwift Recipe `component-root-tab-view` with CustomerRootTabView.
//

import SwiftUI
import SwiftData

struct OwnerRootTabView: View {
    @State private var selectedTab = "orders"

    var body: some View {
        TabView(selection: $selectedTab) {
            // MARK: Orders
            Tab(value: "orders") {
                NavigationStack {
                    OrdersBoardView()
                }
            } label: {
                Label {
                    Text("订单")
                } icon: {
                    Image(systemName: selectedTab == "orders" ? "list.bullet.clipboard.fill" : "list.bullet.clipboard")
                }
                .environment(\.symbolVariants, .none)
            }

            // MARK: Menu admin
            Tab(value: "menu") {
                NavigationStack {
                    MenuAdminView()
                }
            } label: {
                Label {
                    Text("菜单")
                } icon: {
                    Image(systemName: selectedTab == "menu" ? "square.grid.2x2.fill" : "square.grid.2x2")
                }
                .environment(\.symbolVariants, .none)
            }

            // MARK: Revenue
            Tab(value: "revenue") {
                NavigationStack {
                    RevenueDashboardView()
                }
            } label: {
                Label {
                    Text("营收")
                } icon: {
                    Image(systemName: selectedTab == "revenue" ? "chart.line.uptrend.xyaxis.circle.fill" : "chart.line.uptrend.xyaxis.circle")
                }
                .environment(\.symbolVariants, .none)
            }

            // MARK: Settings
            Tab(value: "settings") {
                NavigationStack {
                    OwnerSettingsView()
                }
            } label: {
                Label {
                    Text("设置")
                } icon: {
                    Image(systemName: selectedTab == "settings" ? "gearshape.fill" : "gearshape")
                }
                .environment(\.symbolVariants, .none)
            }
        }
        .tint(Color("BobaBrown"))
        .sensoryFeedback(.increase, trigger: selectedTab)
    }

}

#Preview {
    OwnerRootTabView()
        .modelContainer(for: [
            Product.self, CartItem.self, Order.self, Customer.self, Coupon.self
        ], inMemory: true)
}
