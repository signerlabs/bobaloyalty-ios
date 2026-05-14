//
//  OrderDetailView.swift
//  BobaLoyalty
//
//  Order details: per-cup line items + status-transition button
//  (Start preparing / Ready / Picked up).
//  Status machine: pending → making → ready → completed.
//

import SwiftUI
import SwiftData

struct OrderDetailView: View {
    @Bindable var order: Order
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // MARK: Header info card
                headerCard

                // MARK: Item details
                VStack(alignment: .leading, spacing: 12) {
                    Text("Items")
                        .font(.headline)
                        .foregroundStyle(Color("BobaBrown"))

                    VStack(spacing: 0) {
                        ForEach(order.items) { line in
                            orderLineRow(line)
                            if line.id != order.items.last?.id {
                                Divider().padding(.leading, 56)
                            }
                        }
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color(.systemBackground))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color("BobaPearl").opacity(0.5), lineWidth: 0.5)
                    )
                }

                // MARK: Summary
                summaryCard

                // MARK: Status transition button
                actionButtons
            }
            .padding()
        }
        .background(Color("BobaCream").ignoresSafeArea())
        .navigationTitle("Order #\(String(order.id.uuidString.suffix(4)))")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Header card

    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                OrderStatusBadge(status: order.status)
                Spacer()
                Text(order.createdAt.relativeChinese)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            HStack(spacing: 8) {
                Image(systemName: "person.fill")
                    .font(.caption)
                    .foregroundStyle(Color("BobaCaramel"))
                Text("Member \(String(order.customerID.suffix(6)))")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(.systemBackground))
        )
    }

    // MARK: - Single cup line row

    @ViewBuilder
    private func orderLineRow(_ line: OrderLine) -> some View {
        HStack(spacing: 12) {
            // Circular color placeholder + SF Symbol
            ZStack {
                Circle()
                    .fill(Color(line.imageName))
                    .frame(width: 44, height: 44)
                Image(systemName: "cup.and.saucer.fill")
                    .font(.system(size: 18))
                    .foregroundStyle(.white.opacity(0.85))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(line.productName)
                    .font(.subheadline)
                    .fontWeight(.semibold)

                HStack(spacing: 6) {
                    Text(line.size)
                    Text("·").foregroundStyle(.secondary)
                    Text(line.sugar)
                }
                .font(.caption)
                .foregroundStyle(.secondary)

                if !line.addons.isEmpty {
                    Text("Add-ons: " + line.addons.joined(separator: " / "))
                        .font(.caption2)
                        .foregroundStyle(Color("BobaCaramel"))
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text("×\(line.quantity)")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                Text("¥\(line.lineTotal, specifier: "%.0f")")
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 12)
    }

    // MARK: - Summary card

    private var summaryCard: some View {
        VStack(spacing: 10) {
            HStack {
                Text("Total cups")
                Spacer()
                Text("\(order.totalCups) cups")
            }
            .font(.footnote)
            .foregroundStyle(.secondary)

            HStack {
                Text("Points earned")
                Spacer()
                Text("+\(order.pointsEarned)")
                    .foregroundStyle(Color("BobaMatcha"))
            }
            .font(.footnote)

            Divider()

            HStack {
                Text("Total")
                    .font(.headline)
                Spacer()
                Text("¥\(order.totalAmount, specifier: "%.0f")")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(Color("BobaCaramel"))
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(.systemBackground))
        )
    }

    // MARK: - Status transition button

    @ViewBuilder
    private var actionButtons: some View {
        switch order.status {
        case .pending:
            primaryActionButton(title: "Start making", icon: "play.fill") {
                advance(to: .making, message: "Started making")
            }
        case .making:
            primaryActionButton(title: "Ready for pickup", icon: "checkmark.circle.fill") {
                advance(to: .ready, message: "Ready, waiting for pickup")
            }
        case .ready:
            primaryActionButton(title: "Picked up", icon: "hand.thumbsup.fill") {
                advance(to: .completed, message: "Order completed")
            }
        case .completed:
            HStack {
                Image(systemName: "checkmark.seal.fill")
                Text("Order completed")
            }
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
        case .cancelled:
            HStack {
                Image(systemName: "xmark.seal.fill")
                Text("Order cancelled")
            }
            .foregroundStyle(.red)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
        }
    }

    private func primaryActionButton(
        title: String,
        icon: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                Text(title)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color("BobaCaramel"))
            )
            .foregroundStyle(.white)
        }
    }

    // MARK: - Status advancement

    private func advance(to next: OrderStatus, message: String) {
        withAnimation(.spring(duration: 0.4)) {
            order.status = next
        }
        SWAlertManager.shared.show(.success, message: message)
    }
}

#Preview("Making Order") {
    let sampleOrder = Order(
        createdAt: Calendar.current.date(byAdding: .minute, value: -8, to: .now) ?? .now,
        items: [
            OrderLine(
                productName: "Signature Milk Tea",
                size: "Large",
                sugar: "Half Sweet",
                addons: ["Tapioca", "Coconut Jelly"],
                quantity: 2,
                unitPrice: 19,
                imageName: "Drink_NaiCha"
            ),
            OrderLine(
                productName: "Mango Pomelo Sago",
                size: "Medium",
                sugar: "30% Sweet",
                quantity: 1,
                unitPrice: 22,
                imageName: "Drink_YangZhi"
            )
        ],
        totalAmount: 60,
        status: .making,
        pointsEarned: 30,
        customerID: UUID().uuidString
    )
    return NavigationStack {
        OrderDetailView(order: sampleOrder)
    }
    .modelContainer(for: [
        Product.self, CartItem.self, Order.self, Customer.self, Coupon.self
    ], inMemory: true)
}
