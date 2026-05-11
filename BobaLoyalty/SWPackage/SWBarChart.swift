//
//  SWBarChart.swift
//  BobaLoyalty
//
//  ShipSwift Recipe: chart-bar-chart
//  基于 Swift Charts BarMark 的可横向滚动条形图。
//  - 支持分组 / 堆叠两种显示模式
//  - 多系列分类着色
//  - 可选数值标签
//  - 入场动画：bars 从 0 缓慢长到目标值（easeOut 1.2s）
//

import SwiftUI
import Charts

// MARK: - SWBarChart

struct SWBarChart<CategoryType: Hashable & Plottable>: View {
    // MARK: - 枚举

    /// 多系列条形图显示模式
    enum StackMode {
        /// 同日期分桶内并排
        case grouped
        /// 同日期分桶内堆叠
        case stacked
    }

    // MARK: - 数据模型

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

    // MARK: - 属性

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

    /// 入场动画进度（0~1），bars 的 y 值乘以该值实现"从 0 长出"效果
    @State private var animationProgress: Double = 0

    // MARK: - 计算属性

    /// 真实数据范围（动画期间保持稳定，避免 Y 轴随动画刷新）
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

    /// 初始滚动位置：今天居中
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
                        x: .value("日期", point.date, unit: .day),
                        y: .value("数值", point.value * animationProgress)
                    )
                    .foregroundStyle(by: .value("分类", point.category))
                    .position(by: .value("分类", point.category))
                    .clipShape(RoundedRectangle(cornerRadius: barCornerRadius))
                    .annotation(position: .top) {
                        valueLabel(for: point)
                    }
                } else {
                    BarMark(
                        x: .value("日期", point.date, unit: .day),
                        y: .value("数值", point.value * animationProgress)
                    )
                    .foregroundStyle(by: .value("分类", point.category))
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

    // MARK: - 私有辅助

    @ViewBuilder
    private func valueLabel(for point: DataPoint) -> some View {
        if showValueLabels {
            Text("\(Int(point.value))")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Y 轴 domain 辅助

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

// MARK: - String 分类的便利初始化

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
