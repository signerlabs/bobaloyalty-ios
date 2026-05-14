//
//  OwnerSettingsView.swift
//  BobaLoyalty
//
//  Owner-side Tab 4: Settings.
//  - Store: name / business hours
//  - Member ops: broadcast a promo coupon (SWAddSheet asks for the amount) / reset mock data (with a confirm dialog)
//  - Account: sign-in method (mock)
//  - Misc: version / switch role / about
//

import SwiftUI
import SwiftData

struct OwnerSettingsView: View {
    @AppStorage(AppStorageKey.userRole) private var userRoleRaw: String = UserRole.unset.rawValue
    @AppStorage("storeName") private var storeName: String = "WeiBoba · Wangjing"
    @AppStorage("openHours") private var openHours: String = "10:00 - 22:00"

    @Environment(\.modelContext) private var modelContext

    @Query private var customers: [Customer]
    @Query private var products: [Product]
    @Query private var orders: [Order]
    @Query private var coupons: [Coupon]

    @State private var showingPromoSheet = false
    @State private var showingResetConfirm = false
    @State private var showingRoleSwitchConfirm = false

    var body: some View {
        Form {
            // MARK: Store
            Section("Store") {
                LabeledContent("Store name") {
                    TextField("Store name", text: $storeName)
                        .multilineTextAlignment(.trailing)
                        .foregroundStyle(.secondary)
                }
                LabeledContent("Hours") {
                    TextField("Hours", text: $openHours)
                        .multilineTextAlignment(.trailing)
                        .foregroundStyle(.secondary)
                }
                HStack {
                    Image(systemName: "person.2.fill")
                        .foregroundStyle(Color("BobaPink"))
                    Text("Members")
                    Spacer()
                    Text("\(customers.count)")
                        .foregroundStyle(.secondary)
                }
            }

            // MARK: Member ops
            Section("Member ops") {
                Button {
                    showingPromoSheet = true
                } label: {
                    Label {
                        Text("Send promo coupon")
                            .foregroundStyle(.primary)
                    } icon: {
                        Image(systemName: "ticket.fill")
                            .foregroundStyle(Color("BobaCaramel"))
                    }
                }

                Button(role: .destructive) {
                    showingResetConfirm = true
                } label: {
                    Label("Reset Mock Data", systemImage: "arrow.counterclockwise")
                }
            }

            // MARK: Account
            Section("Account") {
                LabeledContent("Sign-in") {
                    HStack(spacing: 6) {
                        Image(systemName: "applelogo")
                        Text("Apple ID")
                    }
                    .foregroundStyle(.secondary)
                }
                LabeledContent("Account") {
                    Text("****@signerlabs.com")
                        .foregroundStyle(.secondary)
                }
            }

            // MARK: Misc
            Section("More") {
                LabeledContent("Version") {
                    Text(appVersion)
                        .foregroundStyle(.secondary)
                }
                NavigationLink {
                    aboutPage
                } label: {
                    Label("About BobaLoyalty", systemImage: "info.circle")
                }
                Button(role: .destructive) {
                    showingRoleSwitchConfirm = true
                } label: {
                    Label("Switch role", systemImage: "arrow.triangle.2.circlepath")
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(Color("BobaCream").ignoresSafeArea())
        .navigationTitle("Settings")
        // Broadcast-coupon sheet
        .sheet(isPresented: $showingPromoSheet) {
            SWAddSheet(
                isPresented: $showingPromoSheet,
                title: "Send promo coupon",
                placeHolderText: "Enter face value (¥), e.g. 5",
                minLines: 1
            ) { input in
                broadcastPromo(amountText: input)
            }
        }
        // Reset-data confirmation
        .alert("Reset Mock Data", isPresented: $showingResetConfirm) {
            Button("Cancel", role: .cancel) {}
            Button("Reset", role: .destructive) {
                resetMockData()
            }
        } message: {
            Text("This will wipe all products, orders, members and coupons, then re-seed.")
        }
        // Switch-role confirmation
        .alert("Switch role", isPresented: $showingRoleSwitchConfirm) {
            Button("Cancel", role: .cancel) {}
            Button("Exit owner mode", role: .destructive) {
                withAnimation(.spring(duration: 0.4)) {
                    userRoleRaw = UserRole.unset.rawValue
                }
                SWAlertManager.shared.show(.info, message: "Exited owner mode")
            }
        } message: {
            Text("You'll return to the role selector.")
        }
    }

    // MARK: - Broadcast a promo coupon

    private func broadcastPromo(amountText: String) {
        let trimmed = amountText.trimmingCharacters(in: .whitespaces)
        guard let amount = Double(trimmed), amount > 0 else {
            SWAlertManager.shared.show(.error, message: "Invalid amount")
            return
        }
        guard !customers.isEmpty else {
            SWAlertManager.shared.show(.warning, message: "No members yet")
            return
        }

        let expires = Calendar.current.date(byAdding: .day, value: 14, to: .now) ?? .now
        for c in customers {
            let coupon = Coupon(
                kind: .promo,
                title: "¥\(Int(amount)) off orders over ¥\(Int(amount * 4))",
                discountValue: amount,
                expiresAt: expires,
                customerID: c.id.uuidString
            )
            modelContext.insert(coupon)
        }
        SWAlertManager.shared.show(.success, message: "Sent to \(customers.count) members")
    }

    // MARK: - Reset mock data

    private func resetMockData() {
        do {
            // Delete every SwiftData entity
            for o in orders { modelContext.delete(o) }
            for p in products { modelContext.delete(p) }
            for c in customers { modelContext.delete(c) }
            for cp in coupons { modelContext.delete(cp) }

            try modelContext.save()

            // Re-seed mock data
            MockSeed.seedIfNeeded(in: modelContext)

            SWAlertManager.shared.show(.success, message: "Mock data reset")
        } catch {
            SWAlertManager.shared.show(.error, message: "Reset failed: \(error.localizedDescription)")
        }
    }

    // MARK: - About page

    private var aboutPage: some View {
        VStack(spacing: 18) {
            Image(systemName: "cup.and.saucer.fill")
                .font(.system(size: 64))
                .foregroundStyle(Color("BobaCaramel"))
            Text("BobaLoyalty")
                .font(.title)
                .fontWeight(.bold)
                .foregroundStyle(Color("BobaBrown"))
            Text("Vibe Coding a bubble tea ordering app\n· ShipSwift demo recording ·")
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
            Spacer()
        }
        .padding(.top, 64)
        .padding(.horizontal, 24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("BobaCream").ignoresSafeArea())
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - App version

    private var appVersion: String {
        let v = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let b = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "v\(v) (\(b))"
    }
}

#Preview("Seeded") {
    NavigationStack {
        OwnerSettingsView()
    }
    .modelContainer(MockSeed.previewContainer)
}
