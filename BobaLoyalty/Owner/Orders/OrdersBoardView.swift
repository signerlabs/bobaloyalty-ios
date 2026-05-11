//
//  OrdersBoardView.swift
//  BobaLoyalty
//
//  老板端 Tab 1：订单实时流
//  - 顶部 3 张状态卡：今日订单数 / 今日营收 / 待处理订单数
//  - 待处理订单数 > 0 时数字红色 + bounce 动画（"叮"声效感）
//  - 下方按时间倒序的订单列表，点击 push 到 OrderDetailView
//

import SwiftUI
import SwiftData

struct OrdersBoardView: View {
    @Environment(\.modelContext) private var modelContext

    /// 全部订单按时间倒序
    @Query(sort: \Order.createdAt, order: .reverse)
    private var orders: [Order]

    // MARK: - 计算

    private var todayStartOfDay: Date {
        Calendar.current.startOfDay(for: .now)
    }

    private var todayOrders: [Order] {
        orders.filter { $0.createdAt >= todayStartOfDay }
    }

    private var todayOrderCount: Int { todayOrders.count }

    private var todayRevenue: Double {
        todayOrders.reduce(0) { $0 + $1.totalAmount }
    }

    private var pendingCount: Int {
        orders.filter { $0.status == .pending }.count
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // MARK: 顶部状态卡
                statsRow

                // MARK: 订单列表
                ordersList
            }
            .padding(.vertical, 12)
        }
        .background(Color("BobaCream").ignoresSafeArea())
        .navigationTitle("订单")
        .onAppear {
            // 没有今日活跃订单时注入演示数据，让视频录屏有戏可看
            OwnerActiveOrderSeed.seedTodayActiveOrdersIfNeeded(in: modelContext)
        }
    }

    // MARK: - 顶部统计行

    private var statsRow: some View {
        HStack(spacing: 12) {
            statCard(
                title: "今日订单",
                value: "\(todayOrderCount)",
                icon: "doc.text.fill",
                tint: Color("BobaCaramel"),
                bouncing: false
            )
            statCard(
                title: "今日营收",
                value: "¥\(Int(todayRevenue))",
                icon: "yensign.circle.fill",
                tint: Color("BobaMatcha"),
                bouncing: false
            )
            statCard(
                title: "待处理",
                value: "\(pendingCount)",
                icon: "bell.fill",
                tint: pendingCount > 0 ? .red : Color("BobaPearl"),
                bouncing: pendingCount > 0
            )
        }
        .padding(.horizontal)
    }

    private func statCard(
        title: String,
        value: String,
        icon: String,
        tint: Color,
        bouncing: Bool
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.footnote)
                    .foregroundStyle(tint)
                    .symbolEffect(.bounce, options: .repeating, isActive: bouncing)
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
            }
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(tint)
                .contentTransition(.numericText())
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(.systemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(tint.opacity(0.18), lineWidth: 1)
        )
    }

    // MARK: - 订单列表

    private var ordersList: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("订单流水")
                    .font(.headline)
                    .foregroundStyle(Color("BobaBrown"))
                Spacer()
                Text("共 \(orders.count) 单")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal)

            if orders.isEmpty {
                ContentUnavailableView(
                    "暂无订单",
                    systemImage: "tray",
                    description: Text("顾客下单后会实时出现在这里")
                )
                .frame(minHeight: 240)
            } else {
                LazyVStack(spacing: 10) {
                    ForEach(orders) { order in
                        NavigationLink {
                            OrderDetailView(order: order)
                        } label: {
                            OrderRowCard(order: order)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 10)
                                .background(
                                    RoundedRectangle(cornerRadius: 14)
                                        .fill(Color(.systemBackground))
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(rowAccent(order).opacity(0.25), lineWidth: 0.8)
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal)
            }
        }
    }

    /// 不同状态订单的边框轻微染色，提升可读性
    private func rowAccent(_ order: Order) -> Color {
        switch order.status {
        case .pending:   .orange
        case .making:    .blue
        case .ready:     .green
        case .completed: Color("BobaPearl")
        case .cancelled: .red
        }
    }
}
