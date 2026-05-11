//
//  OrderRowCard.swift
//  BobaLoyalty
//
//  订单流单行卡片：订单号末 4 位 / 相对时间 / 商品摘要 / 金额 / 状态徽章
//  设计目标：一眼能看到关键信息，pending 订单视觉醒目。
//

import SwiftUI

struct OrderRowCard: View {
    let order: Order

    /// 商品摘要：聚合相同商品名 + 杯数，例如 "招牌奶茶 ×2, 抹茶拿铁 ×1"
    private var itemsSummary: String {
        // 按商品名聚合数量
        let grouped = Dictionary(grouping: order.items, by: \.productName)
        let parts = grouped.map { name, lines in
            let count = lines.reduce(0) { $0 + $1.quantity }
            return "\(name) ×\(count)"
        }
        // 按数量倒序，让大头在前
        return parts.sorted().joined(separator: ", ")
    }

    /// 订单号末 4 位
    private var shortOrderId: String {
        String(order.id.uuidString.suffix(4))
    }

    var body: some View {
        HStack(spacing: 12) {
            // 左侧主信息
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

            // 右侧金额 + 杯数
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
