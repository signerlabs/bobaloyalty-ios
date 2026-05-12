//
//  BobaLoyaltyApp.swift
//  BobaLoyalty
//
//  App entry point:
//  - Injects the SwiftData modelContainer (5 @Models: Product / CartItem / Order / Customer / Coupon)
//  - On launch, MockSeed checks for an empty store and auto-seeds demo data (8 products + 1 member + 30 days of historical orders)
//  - Attaches .swAlert() on the root view to enable global toasts (ShipSwift Recipe: component-alert)
//  - RootRouterView routes to role select / customer / owner based on @AppStorage("userRole")
//

import SwiftUI
import SwiftData

@main
struct BobaLoyaltyApp: App {

    /// Shared SwiftData container, singleton for the App lifecycle
    let modelContainer: ModelContainer

    init() {
        do {
            let schema = Schema([
                Product.self,
                CartItem.self,
                Order.self,
                Customer.self,
                Coupon.self
            ])
            let config = ModelConfiguration(schema: schema)
            modelContainer = try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("[BobaLoyaltyApp] Failed to create ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            RootRouterView()
                .swAlert()
                .task {
                    // Main thread context (guaranteed by @MainActor)
                    MockSeed.seedIfNeeded(in: modelContainer.mainContext)
                }
        }
        .modelContainer(modelContainer)
    }
}
