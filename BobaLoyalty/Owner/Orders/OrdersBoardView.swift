//
//  OrdersBoardView.swift
//  BobaLoyalty
//
//  Owner-side Tab 1: live order stream.
//  - 3 status cards up top: today's order count / today's revenue / pending count
//  - When pending count > 0, the number is red with a bounce animation (a "ding" feel)
//  - Below: reverse-chronological order list; tapping a row pushes OrderDetailView
//

import SwiftUI
import SwiftData

struct OrdersBoardView: View {
    @Environment(\.modelContext) private var modelContext

    /// All orders, reverse-chronological
    @Query(sort: \Order.createdAt, order: .reverse)
    private var orders: [Order]

    // MARK: - Computed

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
                // MARK: Top status cards
                statsRow

                // MARK: Order list
                ordersList
            }
            .padding(.vertical, 12)
        }
        .background(Color("BobaCream").ignoresSafeArea())
        .navigationTitle("订单")
        .onAppear {
            // Inject demo data when today has no active orders, so the demo recording has action
            OwnerActiveOrderSeed.seedTodayActiveOrdersIfNeeded(in: modelContext)
        }
    }

    // MARK: - Top stats row

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

    // MARK: - Order list

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

    /// Tint the row's border based on order status for better scannability
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
