//
//  SWRootTabView.swift
//  BobaLoyalty
//
//  ShipSwift Recipe: component-root-tab-view.
//  iOS 18+ Tab API template: selected/unselected icon swapping + haptic feedback.
//  Key detail: `.environment(\.symbolVariants, .none)` prevents the system from auto-filling icons.
//
//  In BobaLoyalty we don't use this file directly; instead, we follow this pattern to
//  build CustomerRootTabView and OwnerRootTabView, reusing the "selected-state swap +
//  haptic feedback" details distilled from ShipSwift. This file is kept as a reference template.
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
