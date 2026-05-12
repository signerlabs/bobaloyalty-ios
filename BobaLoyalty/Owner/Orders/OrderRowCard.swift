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
