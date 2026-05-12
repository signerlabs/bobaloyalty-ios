//
//  PointsView.swift
//  BobaLoyalty
//
//  Customer-side points center:
//  - Top: nested SWRingChart with two rings
//      Outer ring (BobaCaramel) = progress toward the next free drink (value = totalPoints % 100, max = 100)
//      Inner ring (BobaMatcha)  = orders this month (value = monthly order count, max = 20)
//      Center: large `totalPoints` + small "积分" (points) label
//  - When totalPoints >= 100, show a "Redeem free drink" button (deducts 100 points and issues a promo coupon)
//  - My coupons (`@Query var coupons`)
//  - Recent purchases (`@Query var orders`, reversed)
//

import SwiftUI
import SwiftData

struct PointsView: View {
    @Query private var customers: [Customer]
    @Query(sort: \Coupon.issuedAt, order: .reverse) private var coupons: [Coupon]
    @Query(sort: \Order.createdAt, order: .reverse) private var orders: [Order]

    @Environment(\.modelContext) private var modelContext

    /// Current member (take the first; BobaLoyalty mock has only one member)
    private var customer: Customer? { customers.first }

    /// Orders this month
    private var monthlyOrderCount: Int {
        guard let customer else { return 0 }
        return orders.filter {
            $0.customerID == customer.id.uuidString &&
            Calendar.current.isDate($0.createdAt, equalTo: .now, toGranularity: .month)
        }.count
    }

    /// Current member's orders (reversed)
    private var myOrders: [Order] {
        guard let customer else { return [] }
        return orders.filter { $0.customerID == customer.id.uuidString }
    }

    /// Current member's coupons (filtered by member; both used and unused are listed)
    private var myCoupons: [Coupon] {
        guard let customer else { return [] }
        return coupons.filter { $0.customerID == customer.id.uuidString }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                ringSection
                redeemButton
                couponsSection
                ordersSection
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
        }
        .background(Color("BobaPearl").ignoresSafeArea())
        .scrollIndicators(.hidden)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("我的积分")
                    .font(.headline)
                    .foregroundStyle(Color("BobaBrown"))
            }
        }
    }

    // MARK: - Ring chart section

    private var ringSection: some View {
        VStack(spacing: 14) {
            let total = customer?.totalPoints ?? 0
            let progress = Double(total % 100)
            let monthly = Double(min(monthlyOrderCount, 20))

            SWRingChart(
                data: [
                    .init(label: "距离免费", value: progress, color: Color("BobaCaramel")),
                    .init(label: "本月杯数", value: monthly, color: Color("BobaMatcha"))
                ],
                maxValue: 100,
                size: 240,
                ringWidth: 22,
                spacing: 10
            ) {
                VStack(spacing: 2) {
                    Text("\(total)")
                        .font(.system(size: 46, weight: .heavy, design: .rounded))
                        .foregroundStyle(Color("BobaBrown"))
                        .contentTransition(.numericText())
                    Text("积分")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            if let c = customer {
                Text("还差 \(c.pointsToNextReward) 分换免费一杯")
                    .font(.subheadline)
                    .foregroundStyle(Color("BobaBrown").opacity(0.75))
            }
        }
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity)
        .background(Color.white, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
    }

    // MARK: - Redeem button (shown only when totalPoints >= 100)

    @ViewBuilder
    private var redeemButton: some View {
        if let c = customer, c.totalPoints >= 100 {
            Button {
                redeemFreeDrink(customer: c)
            } label: {
                HStack {
                    Image(systemName: "gift.fill")
                    Text("兑换免费一杯（-100 积分）")
                        .font(.headline)
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, minHeight: 52)
                .background(Color("BobaCaramel"), in: Capsule())
            }
            .buttonStyle(.plain)
            .sensoryFeedback(.success, trigger: c.totalPoints)
        }
    }

    // MARK: - Coupons section

    private var couponsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("我的优惠券", icon: "ticket.fill")

            if myCoupons.isEmpty {
                Text("暂无优惠券，多下单即可解锁专属券")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, minHeight: 60)
                    .background(Color.white, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            } else {
                VStack(spacing: 8) {
                    ForEach(myCoupons) { coupon in
                        CouponRow(coupon: coupon) {
                            redeemCoupon(coupon)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Recent purchases section

    private var ordersSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("最近消费", icon: "clock.arrow.circlepath")

            if myOrders.isEmpty {
                Text("还没有消费记录")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, minHeight: 60)
                    .background(Color.white, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            } else {
                VStack(spacing: 8) {
                    ForEach(myOrders.prefix(10)) { order in
                        OrderRow(order: order)
                    }
                }
            }
        }
    }

    // MARK: - Actions

    private func redeemFreeDrink(customer: Customer) {
        customer.totalPoints -= 100
        let coupon = Coupon(
            kind: .promo,
            title: "免费一杯（积分兑换）",
            discountValue: 16.0,
            expiresAt: Calendar.current.date(byAdding: .day, value: 30, to: .now) ?? .now,
            customerID: customer.id.uuidString
        )
        modelContext.insert(coupon)
        SWAlertManager.shared.show(.success, message: "兑换成功，已发券到账")
    }

    private func redeemCoupon(_ coupon: Coupon) {
        coupon.isRedeemed = true
        coupon.redeemedAt = .now
        SWAlertManager.shared.show(.success, message: "已核销：\(coupon.title)")
    }

    private func sectionHeader(_ title: String, icon: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(Color("BobaCaramel"))
            Text(title)
                .font(.subheadline.bold())
                .foregroundStyle(Color("BobaBrown"))
            Spacer()
        }
    }
}

// MARK: - Coupon row

private struct CouponRow: View {
    let coupon: Coupon
    let onUse: () -> Void

    private var bgColor: Color {
        switch coupon.kind {
        case .birthday: Color("BobaPink")
        case .promo:    Color("BobaCaramel")
        }
    }

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(bgColor.opacity(0.18))
                    .frame(width: 44, height: 44)
                Image(systemName: coupon.kind.iconName)
                    .foregroundStyle(bgColor)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(coupon.title)
                    .font(.subheadline.bold())
                    .foregroundStyle(Color("BobaBrown"))
                HStack(spacing: 6) {
                    Text(coupon.kind.displayName)
                        .font(.caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(bgColor.opacity(0.18), in: Capsule())
                        .foregroundStyle(bgColor)
                    Text("有效期至 \(coupon.expiresAt.formatted(.dateTime.year().month().day()))")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()

            if coupon.isRedeemed {
                Text("已核销")
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.secondary.opacity(0.1), in: Capsule())
            } else if coupon.isExpired {
                Text("已过期")
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.secondary.opacity(0.1), in: Capsule())
            } else {
                Button("使用", action: onUse)
                    .font(.caption.bold())
                    .foregroundStyle(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 6)
                    .background(bgColor, in: Capsule())
                    .buttonStyle(.plain)
            }
        }
        .padding(12)
        .background(Color.white, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

// MARK: - Order row

private struct OrderRow: View {
    let order: Order

    private var itemSummary: String {
        let names = order.items.map { $0.productName }
        if names.count <= 2 {
            return names.joined(separator: "、")
        }
        return names.prefix(2).joined(separator: "、") + " 等"
    }

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            DrinkThumbnail(
                imageName: order.items.first?.imageName ?? "Drink_NaiCha",
                size: 48,
                cornerRadius: 10
            )

            VStack(alignment: .leading, spacing: 3) {
                Text(itemSummary)
                    .font(.subheadline.bold())
                    .foregroundStyle(Color("BobaBrown"))
                    .lineLimit(1)
                Text("\(order.createdAt.formatted(.dateTime.month().day().hour().minute())) · \(order.totalCups) 杯")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            Spacer()

            VStack(alignment: .trailing, spacing: 3) {
                Text("¥\(String(format: "%.0f", order.totalAmount))")
                    .font(.subheadline.bold())
                    .foregroundStyle(Color("BobaCaramel"))
                Text("+\(order.pointsEarned) 分")
                    .font(.caption2)
                    .foregroundStyle(Color("BobaMatcha"))
            }
        }
        .padding(12)
        .background(Color.white, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

#Preview {
    NavigationStack {
        PointsView()
    }
    .modelContainer(for: [
        Product.self, CartItem.self, Order.self, Customer.self, Coupon.self
    ], inMemory: true)
}
