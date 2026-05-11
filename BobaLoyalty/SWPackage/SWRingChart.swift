//
//  SWRingChart.swift
//  BobaLoyalty
//
//  ShipSwift Recipe: chart-ring-chart
//  Apple Watch 风格嵌套环形进度图：appear 时各环从 0 弹到目标值
//  纯 SwiftUI 实现，不依赖 Swift Charts；支持泛型 ViewBuilder 中央内容
//

import SwiftUI

struct SWRingChart<Center: View>: View {
    // MARK: - 内置数据模型

    struct DataPoint: Identifiable {
        let id = UUID()
        let label: String
        let value: Double
        let color: Color
    }

    // MARK: - Properties

    /// 环数据数组（第一个元素是最外环）
    let data: [DataPoint]

    /// 环的最大量程
    var maxValue: Double = 100

    /// 整体 chart 尺寸
    var size: CGFloat = 250

    /// 单环线宽
    var ringWidth: CGFloat = 25

    /// 嵌套环之间的间距
    var spacing: CGFloat = 10

    /// 中央内容
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

                    // 背景环（淡色）
                    Circle()
                        .stroke(
                            item.color.opacity(0.15),
                            style: StrokeStyle(lineWidth: ringWidth, lineCap: .round)
                        )
                        .frame(width: ringSize, height: ringSize)

                    // 进度环
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

            // 图例
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

    // MARK: - 私有子组件

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

// MARK: - 便捷初始化（无 center 内容）

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
