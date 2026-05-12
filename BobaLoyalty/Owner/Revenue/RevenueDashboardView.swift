//
//  RevenueDashboardView.swift
//  BobaLoyalty
//
//  Owner-side Tab 3: revenue dashboard (the demo-video money shot).
//
//  Visual layout:
//  - Top 2×2 KPI cards: today's revenue / today's cups / this month's revenue / new members this month
//  - Three charts (each in a white rounded card with shadow and a BobaBrown title):
//    1. SWBarChart   — bar chart of daily revenue over the last 7 days
//    2. SWLineChart  — line chart of order count over the last 30 days, with a daily-average reference line
//    3. SWDonutChart — share of product sales, tap to highlight a slice
//
//  Data computation: aggregated in View-level computed properties directly from the @Query-fetched orders.
//  No ViewModel layer (mock data is small enough that recomputing per render is fine).
//

import SwiftUI
import SwiftData
import Charts

struct RevenueDashboardView: View {
    @Query(sort: \Order.createdAt, order: .reverse)
    private var orders: [Order]

    @Query private var customers: [Customer]

    /// Selected donut-chart category
    @State private var selectedProductName: String?

    // MARK: - Time anchors

    private let calendar = Calendar.current
    private var startOfToday: Date { calendar.startOfDay(for: .now) }
    private var startOfYesterday: Date {
        calendar.date(byAdding: .day, value: -1, to: startOfToday) ?? startOfToday
    }
    private var startOfThisMonth: Date {
        calendar.date(from: calendar.dateComponents([.year, .month], from: .now)) ?? startOfToday
    }

    // MARK: - Top KPIs

    private var todayOrders: [Order] {
        orders.filter { $0.createdAt >= startOfToday }
    }
    private var yesterdayOrders: [Order] {
        orders.filter { $0.createdAt >= startOfYesterday && $0.createdAt < startOfToday }
    }
    private var thisMonthOrders: [Order] {
        orders.filter { $0.createdAt >= startOfThisMonth }
    }

    private var todayRevenue: Double {
        todayOrders.reduce(0) { $0 + $1.totalAmount }
    }
    private var yesterdayRevenue: Double {
        yesterdayOrders.reduce(0) { $0 + $1.totalAmount }
    }

    /// Today-vs-yesterday percent change; nil when yesterday has no data to compare against
    private var todayDeltaPercent: Double? {
        guard yesterdayRevenue > 0 else { return nil }
        return (todayRevenue - yesterdayRevenue) / yesterdayRevenue * 100
    }

    private var todayCups: Int {
        todayOrders.reduce(0) { $0 + $1.totalCups }
    }
    private var monthRevenue: Double {
        thisMonthOrders.reduce(0) { $0 + $1.totalAmount }
    }
    private var monthlyNewMembers: Int {
        customers.filter { $0.joinedAt >= startOfThisMonth }.count
    }

    // MARK: - Chart data

    /// Daily revenue over the last 7 days (for the bar chart)
    private var last7DaysRevenue: [SWBarChart<String>.DataPoint] {
        (0..<7).compactMap { offset in
            guard let dayStart = calendar.date(byAdding: .day, value: -offset, to: startOfToday),
                  let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart) else {
                return nil
            }
            let total = orders
                .filter { $0.createdAt >= dayStart && $0.createdAt < dayEnd }
                .reduce(0.0) { $0 + $1.totalAmount }
            return SWBarChart<String>.DataPoint(
                date: dayStart,
                value: total,
                category: "营收"
            )
        }
    }

    /// Order count over the last 30 days (for the line chart)
    private var last30DaysOrderCount: [SWLineChart<String>.DataPoint] {
        (0..<30).compactMap { offset in
            guard let dayStart = calendar.date(byAdding: .day, value: -offset, to: startOfToday),
                  let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart) else {
                return nil
            }
            let count = orders
                .filter { $0.createdAt >= dayStart && $0.createdAt < dayEnd }
                .count
            return SWLineChart<String>.DataPoint(
                date: dayStart,
                value: Double(count),
                category: "订单数"
            )
        }
    }

    /// 30-day daily average order count (used as the line chart's reference line)
    private var avgDailyOrderCount: Double {
        let totalCount = last30DaysOrderCount.reduce(0.0) { $0 + $1.value }
        return totalCount / 30
    }

    /// Product sales share (each cup counts as one Subject)
    private var productMixSubjects: [SWDonutChart.Subject] {
        var subjects: [SWDonutChart.Subject] = []
        for order in orders {
            for line in order.items {
                let category = SWDonutChart.Category(name: line.productName)
                for _ in 0..<line.quantity {
                    subjects.append(
                        SWDonutChart.Subject(
                            name: line.productName,
                            category: category
                        )
                    )
                }
            }
        }
        return subjects
    }

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                // Top 4 KPI cards
                kpiGrid

                // Three charts
                chartCard(title: "近 7 天营收") {
                    SWBarChart(
                        dataPoints: last7DaysRevenue,
                        colorMapping: ["营收": Color("BobaCaramel")],
                        showValueLabels: true,
                        barCornerRadius: 6,
                        visibleDays: 7,
                        chartHeight: 200
                    )
                }

                chartCard(title: "近 30 天订单趋势") {
                    SWLineChart(
                        dataPoints: last30DaysOrderCount,
                        colorMapping: ["订单数": Color("BobaMatcha")],
                        referenceLines: [
                            .init(
                                value: avgDailyOrderCount,
                                label: "日均 \(String(format: "%.1f", avgDailyOrderCount))",
                                color: Color("BobaPink")
                            )
                        ],
                        interpolationMethod: .catmullRom,
                        showPointMarkers: true,
                        visibleDays: 14,
                        chartHeight: 220
                    )
                }

                chartCard(title: "商品销量占比") {
                    SWDonutChart(
                        subjects: productMixSubjects,
                        selectedCategory: $selectedProductName
                    )
                    .padding(.bottom, 8)
                }
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 14)
        }
        .background(Color("BobaCream").ignoresSafeArea())
        .navigationTitle("营收看板")
    }

    // MARK: - Top KPI grid

    private var kpiGrid: some View {
        let columns = [
            GridItem(.flexible(), spacing: 12),
            GridItem(.flexible(), spacing: 12)
        ]
        return LazyVGrid(columns: columns, spacing: 12) {
            kpiCard(
                title: "今日营收",
                value: "¥\(Int(todayRevenue))",
                icon: "yensign.circle.fill",
                tint: Color("BobaCaramel"),
                trailing: deltaTag(todayDeltaPercent)
            )
            kpiCard(
                title: "今日杯数",
                value: "\(todayCups)",
                icon: "cup.and.saucer.fill",
                tint: Color("BobaBrown"),
                trailing: AnyView(unitTag("杯"))
            )
            kpiCard(
                title: "本月营收",
                value: "¥\(Int(monthRevenue))",
                icon: "calendar",
                tint: Color("BobaMatcha"),
                trailing: AnyView(monthRangeTag())
            )
            kpiCard(
                title: "本月新增会员",
                value: "\(monthlyNewMembers)",
                icon: "person.2.fill",
                tint: Color("BobaPink"),
                trailing: AnyView(unitTag("人"))
            )
        }
    }

    private func kpiCard(
        title: String,
        value: String,
        icon: String,
        tint: Color,
        trailing: AnyView
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundStyle(tint)
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
            trailing
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
        )
        .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(tint.opacity(0.15), lineWidth: 1)
        )
    }

    /// Percent-change tag
    private func deltaTag(_ delta: Double?) -> AnyView {
        guard let delta else {
            return AnyView(
                Text("昨日无数据")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            )
        }
        let isUp = delta >= 0
        return AnyView(
            HStack(spacing: 4) {
                Image(systemName: isUp ? "arrow.up.right" : "arrow.down.right")
                    .font(.caption2)
                Text(String(format: "%@%.1f%% vs 昨日", isUp ? "+" : "", delta))
                    .font(.caption2)
            }
            .foregroundStyle(isUp ? Color("BobaMatcha") : .red)
        )
    }

    private func unitTag(_ unit: String) -> some View {
        Text("单位：\(unit)")
            .font(.caption2)
            .foregroundStyle(.secondary)
    }

    private func monthRangeTag() -> some View {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "M月起"
        return Text(formatter.string(from: startOfThisMonth))
            .font(.caption2)
            .foregroundStyle(.secondary)
    }

    // MARK: - Chart card

    @ViewBuilder
    private func chartCard<Content: View>(
        title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(Color("BobaBrown"))
                Spacer()
                Image(systemName: "chart.xyaxis.line")
                    .font(.caption)
                    .foregroundStyle(Color("BobaCaramel"))
            }
            content()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color(.systemBackground))
        )
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 3)
    }
}
