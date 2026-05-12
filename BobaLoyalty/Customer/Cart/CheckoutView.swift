//
//  CheckoutView.swift
//  BobaLoyalty
//
//  Checkout page: order summary + payment-method picker + mock payment.
//  - Two big buttons (WeChat Pay / Alipay), visual only with no SDK
//  - On tap → `SWLoadingManager.shared.show(page: .checkout, ...)` for 1 second
//  - After 1s: write the Order (pointsEarned = cups × 10), add to Customer.totalPoints,
//    clear CartItems, show a success toast, and dismiss back to the previous screen.
//

import SwiftUI
import SwiftData

struct CheckoutView: View {
    @Query(sort: \CartItem.addedAt, order: .reverse) private var cartItems: [CartItem]
    @Query private var customers: [Customer]
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var selectedPay: PayMethod = .wechat
    @State private var isPaying = false

    /// Total amount
    private var totalAmount: Double {
        cartItems.reduce(0.0) { $0 + $1.lineTotal }
    }

    /// Total cup count
    private var totalCups: Int {
        cartItems.reduce(0) { $0 + $1.quantity }
    }

    /// Points earned by this order
    private var pointsEarned: Int {
        totalCups * 10
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                summaryCard
                pointsCard
                paymentSection
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
        }
        .background(Color("BobaPearl").ignoresSafeArea())
        .scrollIndicators(.hidden)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("确认订单")
                    .font(.headline)
                    .foregroundStyle(Color("BobaBrown"))
            }
        }
        .safeAreaInset(edge: .bottom) {
            payButton
        }
        .swPageLoading(.checkout)
        .disabled(isPaying)
    }

    // MARK: - Order summary

    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("订单明细", icon: "list.bullet.rectangle.portrait")

            VStack(spacing: 10) {
                ForEach(cartItems) { item in
                    HStack(alignment: .top, spacing: 10) {
                        DrinkThumbnail(
                            imageName: item.product?.imageName ?? "Drink_NaiCha",
                            size: 48,
                            cornerRadius: 10
                        )
                        VStack(alignment: .leading, spacing: 2) {
                            Text(item.product?.name ?? "商品")
                                .font(.subheadline.bold())
                                .foregroundStyle(Color("BobaBrown"))
                            Text("\(item.size) · \(item.sugar)\(item.addons.isEmpty ? "" : " · " + item.addons.joined(separator: "/"))")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 2) {
                            Text("× \(item.quantity)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text("¥\(String(format: "%.0f", item.lineTotal))")
                                .font(.subheadline.bold())
                                .foregroundStyle(Color("BobaCaramel"))
                        }
                    }
                }
            }

            Divider()

            HStack {
                Text("合计 \(totalCups) 杯")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text("¥")
                        .font(.subheadline)
                        .foregroundStyle(Color("BobaCaramel"))
                    Text("\(String(format: "%.0f", totalAmount))")
                        .font(.title2.bold())
                        .foregroundStyle(Color("BobaCaramel"))
                }
            }
        }
        .padding(16)
        .background(Color.white, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    // MARK: - Points preview

    private var pointsCard: some View {
        HStack(spacing: 12) {
            Image(systemName: "star.circle.fill")
                .font(.title2)
                .foregroundStyle(Color("BobaCaramel"))
            VStack(alignment: .leading, spacing: 2) {
                Text("本单可得")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text("+\(pointsEarned) 积分")
                    .font(.subheadline.bold())
                    .foregroundStyle(Color("BobaBrown"))
            }
            Spacer()
            Text("满 100 分免费一杯")
                .font(.caption2)
                .foregroundStyle(Color("BobaCaramel"))
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Color("BobaCream"), in: Capsule())
        }
        .padding(14)
        .background(Color.white, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    // MARK: - Payment method

    private var paymentSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("支付方式", icon: "creditcard.fill")

            VStack(spacing: 8) {
                ForEach(PayMethod.allCases, id: \.self) { method in
                    payRow(method)
                }
            }
        }
        .padding(16)
        .background(Color.white, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    @ViewBuilder
    private func payRow(_ method: PayMethod) -> some View {
        let isOn = selectedPay == method
        Button {
            withAnimation(.spring(duration: 0.25)) {
                selectedPay = method
            }
        } label: {
            HStack(spacing: 12) {
                Image(systemName: method.icon)
                    .font(.title3)
                    .frame(width: 36, height: 36)
                    .foregroundStyle(method.color)
                    .background(method.color.opacity(0.12), in: Circle())

                Text(method.displayName)
                    .font(.subheadline.bold())
                    .foregroundStyle(Color("BobaBrown"))

                Spacer()

                Image(systemName: isOn ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(isOn ? Color("BobaCaramel") : .secondary.opacity(0.4))
            }
            .padding(12)
            .background(
                isOn ? Color("BobaCream").opacity(0.6) : Color("BobaPearl"),
                in: RoundedRectangle(cornerRadius: 14, style: .continuous)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(isOn ? Color("BobaCaramel") : .clear, lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.selection, trigger: isOn)
    }

    // MARK: - Pay button

    private var payButton: some View {
        Button {
            payNow()
        } label: {
            HStack {
                Image(systemName: selectedPay.icon)
                Text("立即支付 ¥\(String(format: "%.0f", totalAmount))")
            }
            .font(.title3.bold())
            .frame(maxWidth: .infinity, minHeight: 54)
            .background(selectedPay.color, in: Capsule())
            .foregroundStyle(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .buttonStyle(.plain)
        .background(.ultraThinMaterial)
    }

    // MARK: - Mock payment logic

    private func payNow() {
        guard !cartItems.isEmpty else {
            SWAlertManager.shared.show(.warning, message: "购物车为空")
            return
        }

        isPaying = true
        SWLoadingManager.shared.show(
            page: .checkout,
            message: "\(selectedPay.displayName)支付中...",
            systemImage: selectedPay.icon
        )

        // Mock a 1-second payment
        Task {
            try? await Task.sleep(for: .seconds(1))
            await finalizeOrder()
        }
    }

    @MainActor
    private func finalizeOrder() async {
        // 1. Convert each CartItem into an OrderLine embedded in the Order
        let lines = cartItems.map { ci in
            OrderLine(
                productName: ci.product?.name ?? "商品",
                size: ci.size,
                sugar: ci.sugar,
                addons: ci.addons,
                quantity: ci.quantity,
                unitPrice: ci.unitPrice,
                imageName: ci.product?.imageName ?? "Drink_NaiCha"
            )
        }

        // 2. Get or create the member
        let customer: Customer
        if let first = customers.first {
            customer = first
        } else {
            let new = Customer(nickname: "奶茶达人 #\(Int.random(in: 1000...9999))")
            modelContext.insert(new)
            customer = new
        }

        // 3. Write the order
        let order = Order(
            items: lines,
            totalAmount: totalAmount,
            status: .completed,
            pointsEarned: pointsEarned,
            customerID: customer.id.uuidString
        )
        modelContext.insert(order)

        // 4. Accumulate points
        customer.totalPoints += pointsEarned

        // 5. Empty the cart
        for item in cartItems {
            modelContext.delete(item)
        }

        // 6. Wrap up
        SWLoadingManager.shared.hide(page: .checkout)
        SWAlertManager.shared.show(.success, message: "支付成功 +\(pointsEarned) 积分")
        isPaying = false
        dismiss()
    }

    // MARK: - Reusable section header

    private func sectionHeader(_ title: String, icon: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(Color("BobaCaramel"))
            Text(title)
                .font(.subheadline.bold())
                .foregroundStyle(Color("BobaBrown"))
        }
    }
}

// MARK: - Payment method

private enum PayMethod: CaseIterable {
    case wechat
    case alipay

    var displayName: String {
        switch self {
        case .wechat: "微信支付"
        case .alipay: "支付宝"
        }
    }

    var icon: String {
        switch self {
        case .wechat: "message.fill"
        case .alipay: "a.circle.fill"
        }
    }

    var color: Color {
        switch self {
        case .wechat: Color(red: 0.16, green: 0.74, blue: 0.32)
        case .alipay: Color(red: 0.10, green: 0.62, blue: 0.91)
        }
    }
}

#Preview {
    NavigationStack {
        CheckoutView()
    }
    .modelContainer(for: [
        Product.self, CartItem.self, Order.self, Customer.self, Coupon.self
    ], inMemory: true)
}
