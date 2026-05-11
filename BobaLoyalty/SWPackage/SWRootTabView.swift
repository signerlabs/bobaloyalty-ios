//
//  SWRootTabView.swift
//  BobaLoyalty
//
//  ShipSwift Recipe: component-root-tab-view
//  iOS 18+ Tab API 模板：选中/未选中图标切换 + 触觉反馈
//  关键：.environment(\.symbolVariants, .none) 阻止系统自动填充图标
//
//  在 BobaLoyalty 中我们不直接用本文件，而是参考此模式实现两套
//  CustomerRootTabView / OwnerRootTabView，把"选中态切换 + 触觉反馈"
//  这些 ShipSwift 沉淀的细节直接复用。本文件保留作为模板参照。
//

import SwiftUI

struct SWRootTabView: View {
    @State private var selectedTab = "home"
    @State private var searchText = ""

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab(value: "home") {
                NavigationStack {
                    ScrollView {
                        ContentUnavailableView("Home", systemImage: "house.fill", description: Text("Your main feed and dashboard content goes here."))
                            .containerRelativeFrame(.vertical)
                    }
                    .navigationTitle("Home")
                }
            } label: {
                Label {
                    Text("Home")
                } icon: {
                    Image(systemName: selectedTab == "home" ? "house.fill" : "house")
                }
                .environment(\.symbolVariants, .none)
            }

            Tab(value: "outfit") {
                NavigationStack {
                    ScrollView {
                        ContentUnavailableView("Outfit", systemImage: "tshirt.fill", description: Text("Browse and manage your outfit collections here."))
                            .containerRelativeFrame(.vertical)
                    }
                    .navigationTitle("Outfit")
                }
            } label: {
                Label {
                    Text("Outfit")
                } icon: {
                    Image(systemName: selectedTab == "outfit" ? "tshirt.fill" : "tshirt")
                }
                .environment(\.symbolVariants, .none)
            }

            Tab(value: "setting") {
                NavigationStack {
                    ScrollView {
                        ContentUnavailableView("Settings", systemImage: "gearshape.fill", description: Text("Adjust preferences, account, and app configuration."))
                            .containerRelativeFrame(.vertical)
                    }
                    .navigationTitle("Setting")
                }
            } label: {
                Label {
                    Text("Setting")
                } icon: {
                    Image(systemName: selectedTab == "setting" ? "gearshape.fill" : "gearshape")
                }
                .environment(\.symbolVariants, .none)
            }
        }
        .sensoryFeedback(.increase, trigger: selectedTab)
    }
}
