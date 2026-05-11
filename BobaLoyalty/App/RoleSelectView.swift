//
//  RoleSelectView.swift
//  BobaLoyalty
//
//  首屏角色选择器：奶茶店暖色渐变背景 + "我是顾客" / "我是老板" 两个大按钮
//  选择后写入 @AppStorage，RootRouterView 自动切换到对应根视图
//

import SwiftUI

struct RoleSelectView: View {
    @AppStorage(AppStorageKey.userRole) private var userRoleRaw: String = UserRole.unset.rawValue
    @State private var pressedRole: UserRole?

    var body: some View {
        ZStack {
            // 奶茶暖色渐变背景
            LinearGradient(
                colors: [Color("BobaCream"), Color("BobaCaramel")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 32) {
                Spacer()

                // 品牌标题区
                VStack(spacing: 12) {
                    Image(systemName: "cup.and.saucer.fill")
                        .font(.system(size: 64, weight: .bold))
                        .foregroundStyle(Color("BobaBrown"))

                    Text("BobaLoyalty")
                        .font(.system(size: 42, weight: .heavy, design: .rounded))
                        .foregroundStyle(Color("BobaBrown"))

                    Text("一杯奶茶，一份心意")
                        .font(.subheadline)
                        .foregroundStyle(Color("BobaBrown").opacity(0.75))
                }

                Spacer()

                // 角色选择按钮
                VStack(spacing: 16) {
                    roleButton(
                        role: .customer,
                        title: "我是顾客",
                        subtitle: "扫码点单 · 攒积分 · 收生日券",
                        icon: "person.fill",
                        background: Color("BobaBrown"),
                        foreground: Color("BobaPearl")
                    )

                    roleButton(
                        role: .owner,
                        title: "我是老板",
                        subtitle: "管菜单 · 看营收 · 群发券",
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

    /// 角色按钮：左 icon + 中标题/副标题 + 右箭头
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
                message: role == .customer ? "欢迎光临，请慢慢挑选" : "老板，今日生意兴隆"
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
