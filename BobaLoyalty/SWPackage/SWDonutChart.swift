//
//  SWDonutChart.swift
//  BobaLoyalty
//
//  ShipSwift Recipe: chart-donut-chart
//  基于 Swift Charts SectorMark 的交互式甜甜圈图。
//  - 按 Category 分组聚合
//  - 点击扇区高亮选中（外环放大），中心展示数量与分类名
//  - 未指定 category 的 Subject 自动归入"未分类"
//

import SwiftUI
import Charts

struct SWDonutChart: View {
    // MARK: - 数据模型

    struct Category: Identifiable, Hashable {
        let id: UUID
        let name: String

        init(id: UUID = UUID(), name: String) {
            self.id = id
            self.name = name
        }
    }

    struct Subject: Identifiable {
        let id: UUID
        let name: String
        let category: Category?

        init(id: UUID = UUID(), name: String, category: Category? = nil) {
            self.id = id
            self.name = name
            self.category = category
        }
    }

    // MARK: - 属性

    let subjects: [Subject]
    @Binding var selectedCategory: String?

    private static let noCategoryKey = "__no_category__"

    /// 绑定到 Chart 的累计角度
    @State private var selectedAngle: Int?

    // MARK: - 计算

    private var categoryData: [CategoryItem] {
        let grouped = Dictionary(grouping: subjects) { subject -> String in
            guard let category = subject.category else {
                return Self.noCategoryKey
            }
            return category.name
        }
        return grouped.map { CategoryItem(name: $0.key, count: $0.value.count) }
            .sorted { $0.count != $1.count ? $0.count > $1.count : $0.name < $1.name }
    }

    private var totalCount: Int {
        subjects.count
    }

    private func displayName(for categoryName: String) -> String {
        if categoryName == Self.noCategoryKey {
            return "未分类"
        } else if categoryName.isEmpty {
            return "未命名"
        }
        return categoryName
    }

    private func findCategory(for angle: Int) -> String? {
        var cumulative = 0
        for item in categoryData {
            cumulative += item.count
            if angle <= cumulative {
                return item.name
            }
        }
        return nil
    }

    private var selectedCount: Int {
        guard let selected = selectedCategory else { return totalCount }
        return categoryData.first { $0.name == selected }?.count ?? 0
    }

    private var selectedDisplayName: String {
        guard let selected = selectedCategory else {
            return "全部"
        }
        return displayName(for: selected)
    }

    var body: some View {
        Group {
            if categoryData.isEmpty {
                EmptyView()
            } else {
                Chart(categoryData) { item in
                    let isSelected = selectedCategory == item.name
                    SectorMark(
                        angle: .value("数量", item.count),
                        innerRadius: .ratio(0.6),
                        outerRadius: .ratio(isSelected ? 1.0 : 0.9),
                        angularInset: isSelected ? 2 : 1
                    )
                    .cornerRadius(6)
                    .foregroundStyle(by: .value("分类", displayName(for: item.name)))
                    .opacity(selectedCategory == nil || isSelected ? 1.0 : 0.3)
                }
                .chartLegend(position: .trailing, alignment: .center, spacing: 16)
                .chartAngleSelection(value: $selectedAngle)
                .onChange(of: selectedAngle) { _, newValue in
                    if let angle = newValue, let category = findCategory(for: angle) {
                        selectedCategory = category
                    } else {
                        selectedCategory = nil
                    }
                }
                .animation(.bouncy, value: selectedCategory)
                .chartBackground { proxy in
                    GeometryReader { geometry in
                        if let plotFrame = proxy.plotFrame {
                            let frame = geometry[plotFrame]
                            VStack(spacing: 2) {
                                Text("\(selectedCount)")
                                    .font(.title.bold())
                                Text(selectedDisplayName)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .position(x: frame.midX, y: frame.midY)
                        }
                    }
                }
                .frame(height: 220)
            }
        }
        .padding(.horizontal)
    }

    struct CategoryItem: Identifiable {
        let name: String
        let count: Int

        var id: String { name }
    }
}
