//
//  RoleSelectView.swift
//  BobaLoyalty
//
//  Initial role selector: warm bubble-tea gradient background + two big buttons ("I'm a customer" / "I'm the owner").
//  The choice is written to @AppStorage, and RootRouterView automatically switches to the corresponding root view.
//

import SwiftUI

struct RoleSelectView: View {
    @AppStorage(AppStorageKey.userRole) private var userRoleRaw: String = UserRole.unset.rawValue
    @State private var pressedRole: UserRole?

    var body: some View {
        ZStack {
            // Warm bubble-tea gradient background
            LinearGradient(
                colors: [Color("BobaCream"), Color("BobaCaramel")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 32) {
                Spacer()

                // Brand title section
                VStack(spacing: 12) {
                    Image(systemName: "cup.and.saucer.fill")
                        .font(.system(size: 64, weight: .bold))
                        .foregroundStyle(Color("BobaBrown"))

                    Text("BobaLoyalty")
                        .font(.system(size: 42, weight: .heavy, design: .rounded))
                        .foregroundStyle(Color("BobaBrown"))

                    Text("One cup of boba, one little kindness")
                        .font(.subheadline)
                        .foregroundStyle(Color("BobaBrown").opacity(0.75))
                }

                Spacer()

                // Role selection buttons
                VStack(spacing: 16) {
                    roleButton(
                        role: .customer,
                        title: "I'm a customer",
                        subtitle: "Scan to order · Earn points · Get birthday coupons",
                        icon: "person.fill",
                        background: Color("BobaBrown"),
                        foreground: Color("BobaPearl")
                    )

                    roleButton(
                        role: .owner,
                        title: "I'm the owner",
                        subtitle: "Manage menu · Track revenue · Send promos",
                        icon: "storefront.fill",
                        background: Color("BobaPearl"),
                        foreground: Color("BobaBrown")
                    )
                }
                .padding(.horizontal, 24)

                Spacer()
                    .frame(height: 40)
            }
        }
    }

    /// Role button: icon on the left + title/subtitle in the middle + chevron on the right
    @ViewBuilder
    private func roleButton(
        role: UserRole,
        title: String,
        subtitle: String,
        icon: String,
        background: Color,
        foreground: Color
    ) -> some View {
        Button {
            withAnimation(.spring(duration: 0.4)) {
                userRoleRaw = role.rawValue
            }
            SWAlertManager.shared.show(
                .success,
                message: role == .customer ? "Welcome, take your time" : "Hey boss, here's to a great day"
            )
        } label: {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title2)
                    .frame(width: 44, height: 44)
                    .background(foreground.opacity(0.15), in: Circle())

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(foreground.opacity(0.75))
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.subheadline)
                    .foregroundStyle(foreground.opacity(0.6))
            }
            .foregroundStyle(foreground)
            .padding(.horizontal, 20)
            .padding(.vertical, 18)
            .background(background, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            .scaleEffect(pressedRole == role ? 0.97 : 1.0)
            .animation(.spring(duration: 0.25), value: pressedRole)
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in pressedRole = role }
                .onEnded { _ in pressedRole = nil }
        )
        .sensoryFeedback(.impact(weight: .medium), trigger: userRoleRaw)
    }
}

#Preview {
    RoleSelectView()
}
