//
//  SWBarChart.swift
//  BobaLoyalty
//
//  ShipSwift Recipe: chart-bar-chart.
//  Horizontally scrollable bar chart built on Swift Charts BarMark.
//  - Supports both grouped and stacked display modes
//  - Per-category coloring for multi-series data
//  - Optional value labels
//  - Entrance animation: bars grow from 0 to their target values (easeOut, 1.2s)
//

import SwiftUI
import Charts

// MARK: - SWBarChart

struct SWBarChart<CategoryType: Hashable & Plottable>: View {
    // MARK: - Enums

    /// Display mode for multi-series bars
    enum StackMode {
        /// Side-by-side within the same date bucket
        case grouped
        /// Stacked within the same date bucket
        case stacked
    }

    // MARK: - Data model

    struct DataPoint: Identifiable {
        let id: UUID
        let date: Date
        let value: Double
        let category: CategoryType

        init(id: UUID = UUID(), date: Date, value: Double, category: CategoryType) {
            self.id = id
            self.date = date
            self.value = value
            self.category = category
        }
    }

    // MARK: - Properties

    let dataPoints: [DataPoint]
    let colorMapping: [CategoryType: Color]

    var stackMode: StackMode = .grouped
    var showValueLabels: Bool = false
    var barCornerRadius: CGFloat = 3
    var yDomain: ClosedRange<Double>? = nil
    var scrollableDaysBack: Int = 30
    var scrollableDaysForward: Int = 7
    var visibleDays: Int = 7
    var chartHeight: CGFloat = 200
    var title: String? = nil

    /// Entrance animation progress (0–1); each bar's y value is multiplied by this to achieve the "grow from 0" effect
    @State private var animationProgress: Double = 0

    // MARK: - Computed properties

    /// Effective Y domain (stays stable during the animation to avoid the Y axis jittering with each frame)
    private var effectiveYDomain: ClosedRange<Double>? {
        if let yDomain = yDomain { return yDomain }
        guard !dataPoints.isEmpty else { return nil }

        let maxVal: Double
        if stackMode == .stacked {
            let calendar = Calendar.current
            let grouped = Dictionary(grouping: dataPoints) { calendar.startOfDay(for: $0.date) }
            guard let stackMax = grouped.values.map({ $0.reduce(0) { $0 + $1.value } }).max(), stackMax > 0 else { return nil }
            maxVal = stackMax
        } else {
            guard let singleMax = dataPoints.map(\.value).max(), singleMax > 0 else { return nil }
            maxVal = singleMax
        }
        return 0...maxVal
    }

    private var chartXDomain: ClosedRange<Date> {
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: Date())
        let startDate = calendar.date(byAdding: .day, value: -scrollableDaysBack, to: startOfToday)!
        let endDate = calendar.date(byAdding: .day, value: scrollableDaysForward, to: startOfToday)!
        return startDate...endDate
    }

    /// Initial scroll position: center on today
    private var chartInitialScrollDate: Date {
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: Date())
        let offset = visibleDays / 2
        return calendar.date(byAdding: .day, value: -offset, to: startOfToday)!
    }

    private var visibleDomainLength: Int {
        visibleDays * 24 * 60 * 60
    }

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let title = title {
                Text(title)
                    .font(.title3)
                    .fontWeight(.semibold)
            }

            Chart(dataPoints) { point in
                if stackMode == .grouped {
                    BarMark(
                        x: .value("Date", point.date, unit: .day),
                        y: .value("Value", point.value * animationProgress)
                    )
                    .foregroundStyle(by: .value("Category", point.category))
                    .position(by: .value("Category", point.category))
                    .clipShape(RoundedRectangle(cornerRadius: barCornerRadius))
                    .annotation(position: .top) {
                        valueLabel(for: point)
                    }
                } else {
                    BarMark(
                        x: .value("Date", point.date, unit: .day),
                        y: .value("Value", point.value * animationProgress)
                    )
                    .foregroundStyle(by: .value("Category", point.category))
                    .clipShape(RoundedRectangle(cornerRadius: barCornerRadius))
                    .annotation(position: .top) {
                        valueLabel(for: point)
                    }
                }
            }
            .chartForegroundStyleScale(
                domain: Array(colorMapping.keys),
                range: Array(colorMapping.values)
            )
            .chartXScale(domain: chartXDomain)
            .applyOptionalYDomain(effectiveYDomain)
            .chartScrollableAxes(.horizontal)
            .chartXVisibleDomain(length: visibleDomainLength)
            .chartScrollPosition(initialX: chartInitialScrollDate)
            .chartYAxis {
                AxisMarks(position: .leading, values: .automatic(desiredCount: 5)) { _ in
                    AxisGridLine()
                    AxisValueLabel()
                }
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .day, count: 1)) { _ in
                    AxisGridLine()
                    AxisValueLabel(format: .dateTime.month(.abbreviated).day())
                }
            }
            .chartLegend(position: .top, alignment: .trailing)
            .frame(height: chartHeight)
            .onAppear {
                withAnimation(.easeOut(duration: 1.2).delay(0.2)) {
                    animationProgress = 1.0
                }
            }
        }
    }

    // MARK: - Private helpers

    @ViewBuilder
    private func valueLabel(for point: DataPoint) -> some View {
        if showValueLabels {
            Text("\(Int(point.value))")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Y-axis domain helper

private extension View {
    @ViewBuilder
    func applyOptionalYDomain(_ domain: ClosedRange<Double>?) -> some View {
        if let domain = domain {
            self.chartYScale(domain: domain)
        } else {
            self
        }
    }
}

// MARK: - Convenience initializer for String-based categories

extension SWBarChart where CategoryType == String {
    init(
        dataPoints: [DataPoint],
        colorMapping: [String: Color],
        stackMode: StackMode = .grouped,
        showValueLabels: Bool = false,
        barCornerRadius: CGFloat = 3,
        yDomain: ClosedRange<Double>? = nil,
        scrollableDaysBack: Int = 30,
        scrollableDaysForward: Int = 7,
        visibleDays: Int = 7,
        chartHeight: CGFloat = 200,
        title: String? = nil
    ) {
        self.dataPoints = dataPoints
        self.colorMapping = colorMapping
        self.stackMode = stackMode
        self.showValueLabels = showValueLabels
        self.barCornerRadius = barCornerRadius
        self.yDomain = yDomain
        self.scrollableDaysBack = scrollableDaysBack
        self.scrollableDaysForward = scrollableDaysForward
        self.visibleDays = visibleDays
        self.chartHeight = chartHeight
        self.title = title
    }
}
