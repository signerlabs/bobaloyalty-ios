//
//  SWLineChart.swift
//  BobaLoyalty
//
//  ShipSwift Recipe: chart-line-chart.
//  Horizontally scrollable multi-series line chart built on Swift Charts LineMark.
//  - Supports reference lines (RuleMark)
//  - Configurable interpolation (linear / catmullRom / stepCenter, etc.)
//  - Optional PointMark dot highlights
//  - Entrance animation: values grow from 0 to their targets
//

import SwiftUI
import Charts

// MARK: - SWLineChart

struct SWLineChart<CategoryType: Hashable & Plottable>: View {
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

    /// Horizontal reference line (RuleMark)
    struct ReferenceLine {
        let value: Double
        let label: String?
        let color: Color
        let style: StrokeStyle

        init(
            value: Double,
            label: String? = nil,
            color: Color = .secondary,
            style: StrokeStyle = StrokeStyle(lineWidth: 1, dash: [5, 3])
        ) {
            self.value = value
            self.label = label
            self.color = color
            self.style = style
        }
    }

    // MARK: - Properties

    let dataPoints: [DataPoint]
    let colorMapping: [CategoryType: Color]

    var referenceLines: [ReferenceLine] = []
    var interpolationMethod: InterpolationMethod = .linear
    var showPointMarkers: Bool = false
    var yDomain: ClosedRange<Double>? = nil
    var scrollableDaysBack: Int = 30
    var scrollableDaysForward: Int = 7
    var visibleDays: Int = 7
    var chartHeight: CGFloat = 200
    var title: String? = nil

    /// Entrance animation progress
    @State private var animationProgress: Double = 0

    // MARK: - Computed properties

    private var effectiveYDomain: ClosedRange<Double>? {
        if let yDomain = yDomain { return yDomain }
        let allValues = dataPoints.map(\.value) + referenceLines.map(\.value)
        guard let minVal = allValues.min(), let maxVal = allValues.max(), maxVal > 0 else { return nil }
        return min(minVal, 0)...maxVal
    }

    private var chartXDomain: ClosedRange<Date> {
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: Date())
        let startDate = calendar.date(byAdding: .day, value: -scrollableDaysBack, to: startOfToday)!
        let endDate = calendar.date(byAdding: .day, value: scrollableDaysForward, to: startOfToday)!
        return startDate...endDate
    }

    /// Initial scroll position: anchor the newest data to the right edge
    private var chartInitialScrollDate: Date {
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: Date())
        return calendar.date(byAdding: .day, value: -visibleDays, to: startOfToday)!
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

            Chart {
                ForEach(dataPoints) { point in
                    LineMark(
                        x: .value("Date", point.date),
                        y: .value("Value", point.value * animationProgress)
                    )
                    .foregroundStyle(by: .value("Category", point.category))
                    .interpolationMethod(interpolationMethod)
                    .lineStyle(StrokeStyle(lineWidth: 2))

                    if showPointMarkers {
                        PointMark(
                            x: .value("Date", point.date),
                            y: .value("Value", point.value * animationProgress)
                        )
                        .foregroundStyle(by: .value("Category", point.category))
                        .symbolSize(30)
                    }
                }

                ForEach(Array(referenceLines.enumerated()), id: \.offset) { _, line in
                    RuleMark(y: .value("Reference", line.value * animationProgress))
                        .foregroundStyle(line.color)
                        .lineStyle(line.style)
                        .annotation(position: .top, alignment: .leading) {
                            if let label = line.label {
                                Text(label)
                                    .font(.caption2)
                                    .foregroundStyle(line.color)
                            }
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

extension SWLineChart where CategoryType == String {
    init(
        dataPoints: [DataPoint],
        colorMapping: [String: Color],
        referenceLines: [ReferenceLine] = [],
        interpolationMethod: InterpolationMethod = .linear,
        showPointMarkers: Bool = false,
        yDomain: ClosedRange<Double>? = nil,
        scrollableDaysBack: Int = 30,
        scrollableDaysForward: Int = 7,
        visibleDays: Int = 7,
        chartHeight: CGFloat = 200,
        title: String? = nil
    ) {
        self.dataPoints = dataPoints
        self.colorMapping = colorMapping
        self.referenceLines = referenceLines
        self.interpolationMethod = interpolationMethod
        self.showPointMarkers = showPointMarkers
        self.yDomain = yDomain
        self.scrollableDaysBack = scrollableDaysBack
        self.scrollableDaysForward = scrollableDaysForward
        self.visibleDays = visibleDays
        self.chartHeight = chartHeight
        self.title = title
    }
}
