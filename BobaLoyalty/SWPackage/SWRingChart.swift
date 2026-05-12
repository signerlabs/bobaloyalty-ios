//
//  SWRingChart.swift
//  BobaLoyalty
//
//  ShipSwift Recipe: chart-ring-chart.
//  Apple Watch-style nested ring progress chart; each ring springs from 0 to its target value on appear.
//  Pure SwiftUI implementation (no Swift Charts dependency); supports a generic ViewBuilder for the center content.
//

import SwiftUI

struct SWRingChart<Center: View>: View {
    // MARK: - Built-in data model

    struct DataPoint: Identifiable {
        let id = UUID()
        let label: String
        let value: Double
        let color: Color
    }

    // MARK: - Properties

    /// Ring data array (first element is the outermost ring)
    let data: [DataPoint]

    /// Maximum value the ring represents
    var maxValue: Double = 100

    /// Overall chart size
    var size: CGFloat = 250

    /// Stroke width of a single ring
    var ringWidth: CGFloat = 25

    /// Spacing between nested rings
    var spacing: CGFloat = 10

    /// Center content
    @ViewBuilder let center: () -> Center

    @State private var animatedValues: [Double]

    // MARK: - Init

    init(
        data: [DataPoint],
        maxValue: Double = 100,
        size: CGFloat = 250,
        ringWidth: CGFloat = 25,
        spacing: CGFloat = 10,
        @ViewBuilder center: @escaping () -> Center
    ) {
        self.data = data
        self.maxValue = maxValue
        self.size = size
        self.ringWidth = ringWidth
        self.spacing = spacing
        self.center = center
        self._animatedValues = State(initialValue: Array(repeating: 0, count: data.count))
    }

    // MARK: - Body

    var body: some View {
        VStack {
            ZStack {
                ForEach(Array(data.enumerated()), id: \.element.id) { index, item in
                    let ringIndex = CGFloat(data.count - 1 - index)
                    let ringSize = size - ringIndex * (ringWidth + spacing) * 2

                    // Background ring (faint color)
                    Circle()
                        .stroke(
                            item.color.opacity(0.15),
                            style: StrokeStyle(lineWidth: ringWidth, lineCap: .round)
                        )
                        .frame(width: ringSize, height: ringSize)

                    // Progress ring
                    Circle()
                        .trim(from: 0, to: animatedValues[index] / maxValue)
                        .stroke(
                            item.color,
                            style: StrokeStyle(lineWidth: ringWidth, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                        .frame(width: ringSize, height: ringSize)
                }

                center()
            }

            // Legend
            HStack(spacing: 20) {
                ForEach(data) { item in
                    BulletPointText(bulletColor: item.color) {
                        Text(item.label)

                        Text("\(Int(item.value))")
                            .fontWeight(.semibold)
                    }
                }
            }
            .padding(.top)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.2).delay(0.2)) {
                for i in data.indices {
                    animatedValues[i] = data[i].value
                }
            }
        }
    }

    // MARK: - Private subcomponent

    private struct BulletPointText<Content: View>: View {
        var bulletColor: Color
        @ViewBuilder var content: Content

        var body: some View {
            HStack(spacing: 4) {
                Capsule()
                    .fill(bulletColor)
                    .frame(width: 3, height: 10)

                content
                    .font(.caption)
            }
        }
    }
}

// MARK: - Convenience initializer (no center content)

extension SWRingChart where Center == EmptyView {
    init(
        data: [DataPoint],
        maxValue: Double = 100,
        size: CGFloat = 250,
        ringWidth: CGFloat = 25,
        spacing: CGFloat = 10
    ) {
        self.init(
            data: data,
            maxValue: maxValue,
            size: size,
            ringWidth: ringWidth,
            spacing: spacing
        ) {
            EmptyView()
        }
    }
}
