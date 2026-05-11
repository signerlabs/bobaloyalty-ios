//
//  OrderDetailView.swift
//  BobaLoyalty
//
//  订单详情：每杯明细 + 状态流转按钮（开始制作 / 出餐完成 / 顾客已取）
//  状态机：pending → making → ready → completed
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
                // MARK: 头部信息卡
                headerCard

                // MARK: 商品明细
                VStack(alignment: .leading, spacing: 12) {
                    Text("商品明细")
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

                // MARK: 合计
                summaryCard

                // MARK: 状态流转按钮
                actionButtons
            }
            .padding()
        }
        .background(Color("BobaCream").ignoresSafeArea())
        .navigationTitle("订单 #\(String(order.id.uuidString.suffix(4)))")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - 头部卡

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
                Text("会员 \(String(order.customerID.suffix(6)))")
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

    // MARK: - 单杯明细行

    @ViewBuilder
    private func orderLineRow(_ line: OrderLine) -> some View {
        HStack(spacing: 12) {
            // 占位色圆形 + SF Symbol
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
                    Text("加料：" + line.addons.joined(separator: " / "))
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

    // MARK: - 合计卡

    private var summaryCard: some View {
        VStack(spacing: 10) {
            HStack {
                Text("总杯数")
                Spacer()
                Text("\(order.totalCups) 杯")
            }
            .font(.footnote)
            .foregroundStyle(.secondary)

            HStack {
                Text("本单积分")
                Spacer()
                Text("+\(order.pointsEarned)")
                    .foregroundStyle(Color("BobaMatcha"))
            }
            .font(.footnote)

            Divider()

            HStack {
                Text("合计")
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

    // MARK: - 状态流转按钮

    @ViewBuilder
    private var actionButtons: some View {
        switch order.status {
        case .pending:
            primaryActionButton(title: "开始制作", icon: "play.fill") {
                advance(to: .making, message: "已开始制作")
            }
        case .making:
            primaryActionButton(title: "出餐完成", icon: "checkmark.circle.fill") {
                advance(to: .ready, message: "已出餐，等待自取")
            }
        case .ready:
            primaryActionButton(title: "顾客已取走", icon: "hand.thumbsup.fill") {
                advance(to: .completed, message: "订单完成")
            }
        case .completed:
            HStack {
                Image(systemName: "checkmark.seal.fill")
                Text("订单已完成")
            }
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
        case .cancelled:
            HStack {
                Image(systemName: "xmark.seal.fill")
                Text("订单已取消")
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

    // MARK: - 状态推进

    private func advance(to next: OrderStatus, message: String) {
        withAnimation(.spring(duration: 0.4)) {
            order.status = next
        }
        SWAlertManager.shared.show(.success, message: message)
    }
}
