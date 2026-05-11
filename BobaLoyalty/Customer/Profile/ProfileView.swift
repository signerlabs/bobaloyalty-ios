//
//  ProfileView.swift
//  BobaLoyalty
//
//  顾客端"我的"页：
//  - 会员卡片（昵称 + 总积分 + 加入时间）
//  - 设置生日 DatePicker（若 7 天内将到生日，自动派发生日券）
//  - 切换角色按钮（清 @AppStorage userRole）
//

import SwiftUI
import SwiftData

struct ProfileView: View {
    @Query private var customers: [Customer]
    @Query private var coupons: [Coupon]
    @Environment(\.modelContext) private var modelContext

    @AppStorage(AppStorageKey.userRole) private var userRoleRaw: String = UserRole.unset.rawValue

    @State private var birthday: Date = .now
    @State private var hasBirthday: Bool = false

    private var customer: Customer? { customers.first }

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                memberCard
                birthdayCard
                actionCards
                switchRoleButton
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
        }
        .background(Color("BobaPearl").ignoresSafeArea())
        .scrollIndicators(.hidden)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("我的")
                    .font(.headline)
                    .foregroundStyle(Color("BobaBrown"))
            }
        }
        .onAppear {
            if let b = customer?.birthday {
                birthday = b
                hasBirthday = true
            }
        }
    }

    // MARK: - 会员卡

    private var memberCard: some View {
        ZStack(alignment: .bottomLeading) {
            LinearGradient(
                colors: [Color("BobaBrown"), Color("BobaCaramel")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("会员")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.7))
                        Text(customer?.nickname ?? "未注册")
                            .font(.title3.bold())
                            .foregroundStyle(.white)
                    }
                    Spacer()
                    Image(systemName: "cup.and.saucer.fill")
                        .font(.system(size: 40, weight: .light))
                        .foregroundStyle(.white.opacity(0.45))
                }

                Divider().overlay(.white.opacity(0.25))

                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("总积分")
                            .font(.caption2)
                            .foregroundStyle(.white.opacity(0.7))
                        Text("\(customer?.totalPoints ?? 0)")
                            .font(.title2.bold())
                            .foregroundStyle(.white)
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("加入时间")
                            .font(.caption2)
                            .foregroundStyle(.white.opacity(0.7))
                        Text(customer?.joinedAt.formatted(.dateTime.year().month().day()) ?? "—")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.9))
                    }
                }
            }
            .padding(20)
        }
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .frame(minHeight: 150)
    }

    // MARK: - 生日卡

    private var birthdayCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 6) {
                Image(systemName: "gift.fill")
                    .foregroundStyle(Color("BobaPink"))
                Text("生日福利")
                    .font(.subheadline.bold())
                    .foregroundStyle(Color("BobaBrown"))
                Spacer()
                if hasBirthday {
                    Text("已设置")
                        .font(.caption2)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color("BobaMatcha"), in: Capsule())
                }
            }

            DatePicker(
                "我的生日",
                selection: $birthday,
                displayedComponents: .date
            )
            .datePickerStyle(.compact)
            .tint(Color("BobaCaramel"))

            Button {
                saveBirthday()
            } label: {
                Text(hasBirthday ? "更新生日" : "保存并领取生日券")
                    .font(.subheadline.bold())
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, minHeight: 44)
                    .background(Color("BobaPink"), in: Capsule())
            }
            .buttonStyle(.plain)

            Text("生日前 7 天自动派发一张专属生日券")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .background(Color.white, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    // MARK: - 动作卡片

    private var actionCards: some View {
        VStack(spacing: 0) {
            actionRow(icon: "ticket.fill", title: "我的优惠券", value: "\(activeCouponsCount) 张可用")
            Divider().padding(.leading, 52)
            actionRow(icon: "clock.arrow.circlepath", title: "消费记录", value: "查看历史订单")
            Divider().padding(.leading, 52)
            actionRow(icon: "questionmark.circle", title: "联系商家", value: nil)
        }
        .background(Color.white, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private var activeCouponsCount: Int {
        guard let c = customer else { return 0 }
        return coupons.filter { $0.customerID == c.id.uuidString && $0.isUsable }.count
    }

    private func actionRow(icon: String, title: String, value: String?) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.callout)
                .frame(width: 28, height: 28)
                .foregroundStyle(Color("BobaCaramel"))
                .background(Color("BobaCream"), in: RoundedRectangle(cornerRadius: 8, style: .continuous))

            Text(title)
                .font(.subheadline)
                .foregroundStyle(Color("BobaBrown"))

            Spacer()

            if let value {
                Text(value)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Image(systemName: "chevron.right")
                .font(.caption2)
                .foregroundStyle(.secondary.opacity(0.5))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }

    // MARK: - 切换角色

    private var switchRoleButton: some View {
        Button(role: .destructive) {
            withAnimation(.spring(duration: 0.4)) {
                userRoleRaw = UserRole.unset.rawValue
            }
            SWAlertManager.shared.show(.info, message: "已退出顾客端")
        } label: {
            Label("切换角色", systemImage: "arrow.triangle.2.circlepath")
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
        }
        .buttonStyle(.bordered)
        .padding(.top, 8)
    }

    // MARK: - 生日逻辑

    private func saveBirthday() {
        guard let c = customer else { return }
        c.birthday = birthday
        hasBirthday = true

        if isWithinNext7Days(birthday) {
            // 检查是否已经派过近期生日券，避免重复发
            let alreadyIssued = coupons.contains { coupon in
                coupon.customerID == c.id.uuidString &&
                coupon.kind == .birthday &&
                !coupon.isExpired
            }
            if !alreadyIssued {
                let coupon = Coupon(
                    kind: .birthday,
                    title: "生日特饮免费券",
                    discountValue: 22.0,
                    expiresAt: Calendar.current.date(byAdding: .day, value: 14, to: .now) ?? .now,
                    customerID: c.id.uuidString
                )
                modelContext.insert(coupon)
                SWAlertManager.shared.show(.success, message: "生日快乐！已发券到账")
                return
            }
        }
        SWAlertManager.shared.show(.success, message: "生日已保存")
    }

    /// 生日是否落在未来 7 天内（按当年比对，不看年份）
    private func isWithinNext7Days(_ date: Date) -> Bool {
        let cal = Calendar.current
        let now = Date.now
        let comps: Set<Calendar.Component> = [.month, .day]
        let birthComps = cal.dateComponents(comps, from: date)

        // 找今年的生日
        var thisYear = cal.dateComponents([.year], from: now)
        thisYear.month = birthComps.month
        thisYear.day = birthComps.day
        guard let thisYearBday = cal.date(from: thisYear) else { return false }

        // 若已过，看明年
        let upcoming = thisYearBday < cal.startOfDay(for: now)
            ? (cal.date(byAdding: .year, value: 1, to: thisYearBday) ?? thisYearBday)
            : thisYearBday

        let diff = cal.dateComponents([.day], from: cal.startOfDay(for: now), to: cal.startOfDay(for: upcoming)).day ?? 999
        return diff >= 0 && diff <= 7
    }
}

#Preview {
    NavigationStack {
        ProfileView()
    }
    .modelContainer(for: [
        Product.self, CartItem.self, Order.self, Customer.self, Coupon.self
    ], inMemory: true)
}
