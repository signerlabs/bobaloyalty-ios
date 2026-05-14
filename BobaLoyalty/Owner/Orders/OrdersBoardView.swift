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
        .navigationTitle("Orders")
        .onAppear {
            // Inject demo data when today has no active orders, so the demo recording has action
            OwnerActiveOrderSeed.seedTodayActiveOrdersIfNeeded(in: modelContext)
        }
    }

    // MARK: - Top stats row

    private var statsRow: some View {
        HStack(spacing: 12) {
            statCard(
                title: "Today's Orders",
                value: "\(todayOrderCount)",
                icon: "doc.text.fill",
                tint: Color("BobaCaramel"),
                bouncing: false
            )
            statCard(
                title: "Today's Revenue",
                value: "¥\(Int(todayRevenue))",
                icon: "yensign.circle.fill",
                tint: Color("BobaMatcha"),
                bouncing: false
            )
            statCard(
                title: "Pending",
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
                Text("Order Stream")
                    .font(.headline)
                    .foregroundStyle(Color("BobaBrown"))
                Spacer()
                Text("\(orders.count) total")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal)

            if orders.isEmpty {
                ContentUnavailableView(
                    "No orders yet",
                    systemImage: "tray",
                    description: Text("Customer orders will appear here in real time")
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

#Preview("Seeded") {
    NavigationStack {
        OrdersBoardView()
    }
    .modelContainer(MockSeed.previewContainer)
}
