//
//  OwnerRootTabView.swift
//  BobaLoyalty
//
//  老板端根 TabView：订单 / 菜单管理 / 营收 / 设置
//  与 CustomerRootTabView 共用 ShipSwift Recipe `component-root-tab-view` 的样式约定
//

import SwiftUI
import SwiftData

struct OwnerRootTabView: View {
    @State private var selectedTab = "orders"

    var body: some View {
        TabView(selection: $selectedTab) {
            // MARK: 订单
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

            // MARK: 菜单管理
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

            // MARK: 营收
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

            // MARK: 设置
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
