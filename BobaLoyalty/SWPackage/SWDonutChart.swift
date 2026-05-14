//
//  SWDonutChart.swift
//  BobaLoyalty
//
//  ShipSwift Recipe: chart-donut-chart.
//  An interactive donut chart built on Swift Charts SectorMark.
//  - Aggregates by Category
//  - Tapping a sector highlights it (outer ring grows); the center shows the count and category name
//  - Subjects without a category are bucketed as "Uncategorized"
//

import SwiftUI
import Charts

struct SWDonutChart: View {
    // MARK: - Data model

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

    // MARK: - Properties

    let subjects: [Subject]
    @Binding var selectedCategory: String?

    private static let noCategoryKey = "__no_category__"

    /// Cumulative angle bound to the Chart
    @State private var selectedAngle: Int?

    // MARK: - Computed

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
            return "Uncategorized"
        } else if categoryName.isEmpty {
            return "Unnamed"
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
            return "All"
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
                        angle: .value("Count", item.count),
                        innerRadius: .ratio(0.6),
                        outerRadius: .ratio(isSelected ? 1.0 : 0.9),
                        angularInset: isSelected ? 2 : 1
                    )
                    .cornerRadius(6)
                    .foregroundStyle(by: .value("Category", displayName(for: item.name)))
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
