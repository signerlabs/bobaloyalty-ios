//
//  PointsView.swift
//  BobaLoyalty
//
//  顾客端积分中心：
//  - 顶部：SWRingChart 两环嵌套
//      外环（BobaCaramel）= 距离免费饮品（value = totalPoints % 100，max = 100）
//      内环（BobaMatcha）= 本月消费次数（value = 本月订单数，max = 20）
//      中央：totalPoints 大字 + "积分"小字
//  - 满 100 积分时显示"兑换免费一杯"按钮（-100 积分 + 派发一张 promo 券）
//  - 我的优惠券（@Query var coupons）
//  - 最近消费（@Query var orders 倒序）
//

import SwiftUI
import SwiftData

struct PointsView: View {
    @Query private var customers: [Customer]
    @Query(sort: \Coupon.issuedAt, order: .reverse) private var coupons: [Coupon]
    @Query(sort: \Order.createdAt, order: .reverse) private var orders: [Order]

    @Environment(\.modelContext) private var modelContext

    /// 当前会员（取首位，BobaLoyalty mock 只一个会员）
    private var customer: Customer? { customers.first }

    /// 本月订单数
    private var monthlyOrderCount: Int {
        guard let customer else { return 0 }
        return orders.filter {
            $0.customerID == customer.id.uuidString &&
            Calendar.current.isDate($0.createdAt, equalTo: .now, toGranularity: .month)
        }.count
    }

    /// 当前会员的订单（倒序）
    private var myOrders: [Order] {
        guard let customer else { return [] }
        return orders.filter { $0.customerID == customer.id.uuidString }
    }

    /// 当前会员的可用券（未核销 + 未过期）
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

    // MARK: - 环形图区

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

    // MARK: - 兑换按钮（满 100 才显示）

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

    // MARK: - 优惠券 Section

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

    // MARK: - 最近消费 Section

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

    // MARK: - 子动作

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

// MARK: - 优惠券行

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

// MARK: - 订单行

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
