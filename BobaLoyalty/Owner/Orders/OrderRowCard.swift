//
//  OrderRowCard.swift
//  BobaLoyalty
//
//  Single row card in the order stream: last 4 of the order ID / relative time /
//  item summary / amount / status badge.
//  Design goal: key info at a glance, with pending orders visually prominent.
//

import SwiftUI

struct OrderRowCard: View {
    let order: Order

    /// Item summary: aggregates by product name + cup count, e.g. "招牌奶茶 ×2, 抹茶拿铁 ×1"
    private var itemsSummary: String {
        // Aggregate quantities by product name
        let grouped = Dictionary(grouping: order.items, by: \.productName)
        let parts = grouped.map { name, lines in
            let count = lines.reduce(0) { $0 + $1.quantity }
            return "\(name) ×\(count)"
        }
        // Sort so the largest groups come first
        return parts.sorted().joined(separator: ", ")
    }

    /// Last 4 of the order ID
    private var shortOrderId: String {
        String(order.id.uuidString.suffix(4))
    }

    var body: some View {
        HStack(spacing: 12) {
            // Left-side primary info
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 8) {
                    Text("#\(shortOrderId)")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color("BobaBrown"))
                    OrderStatusBadge(status: order.status)
                }

                Text(itemsSummary)
                    .font(.footnote)
                    .foregroundStyle(.primary)
                    .lineLimit(2)

                HStack(spacing: 6) {
                    Image(systemName: "clock")
                        .font(.caption2)
                    Text(order.createdAt.relativeChinese)
                        .font(.caption2)
                }
                .foregroundStyle(.secondary)
            }

            Spacer()

            // Right-side amount + cup count
            VStack(alignment: .trailing, spacing: 6) {
                Text("¥\(order.totalAmount, specifier: "%.0f")")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(Color("BobaCaramel"))
                Text("\(order.totalCups) 杯")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
    }
}

#Preview("Row Card — Pending & Completed") {
    let sampleLines: [OrderLine] = [
        OrderLine(
            productName: "招牌奶茶",
            size: "大杯",
            sugar: "五分糖",
            addons: ["珍珠"],
            quantity: 2,
            unitPrice: 19,
            imageName: "Drink_NaiCha"
        ),
        OrderLine(
            productName: "抹茶拿铁",
            size: "中杯",
            sugar: "三分糖",
            quantity: 1,
            unitPrice: 18,
            imageName: "Drink_MoCha"
        )
    ]
    let pending = Order(
        createdAt: Calendar.current.date(byAdding: .minute, value: -3, to: .now) ?? .now,
        items: sampleLines,
        totalAmount: 56,
        status: .pending,
        pointsEarned: 30,
        customerID: UUID().uuidString
    )
    let completed = Order(
        createdAt: Calendar.current.date(byAdding: .hour, value: -2, to: .now) ?? .now,
        items: [sampleLines[1]],
        totalAmount: 18,
        status: .completed,
        pointsEarned: 10,
        customerID: UUID().uuidString
    )
    return VStack(spacing: 12) {
        OrderRowCard(order: pending)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(RoundedRectangle(cornerRadius: 14).fill(Color(.systemBackground)))
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(.orange.opacity(0.3), lineWidth: 0.8))
        OrderRowCard(order: completed)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(RoundedRectangle(cornerRadius: 14).fill(Color(.systemBackground)))
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color("BobaPearl").opacity(0.3), lineWidth: 0.8))
    }
    .padding()
    .background(Color("BobaCream").ignoresSafeArea())
}
