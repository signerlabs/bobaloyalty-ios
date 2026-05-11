//
//  CustomerRootTabView.swift
//  BobaLoyalty
//
//  顾客端根 TabView：菜单 / 购物车 / 积分 / 我的
//  四个 tab 全部接入真实页面（任务 #4 #5 #6 完成后接管）
//
//  参考 ShipSwift Recipe `component-root-tab-view` 模式：
//  - iOS 18+ Tab API
//  - 选中/未选中 SF Symbol 切换
//  - .environment(\.symbolVariants, .none) 阻止系统自动填充
//  - .sensoryFeedback 提供触感反馈
//

import SwiftUI
import SwiftData

struct CustomerRootTabView: View {
    @State private var selectedTab = "menu"

    var body: some View {
        TabView(selection: $selectedTab) {
            // MARK: 菜单
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

            // MARK: 购物车
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

            // MARK: 积分
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

            // MARK: 我的
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
