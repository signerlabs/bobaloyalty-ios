//
//  SWOrderSelector.swift
//  BobaLoyalty
//
//  ShipSwift Recipe: component-order-view（Selector 子组件）
//  胶囊形多选切换器，使用 matchedGeometryEffect 让选中态在多个选项间无缝滑动
//  在 BobaLoyalty 用于"杯型/糖度"切换
//

import SwiftUI

struct SWOrderSelector: View {
    let items: [String]
    @Binding var sel: String
    var ns: Namespace.ID
    var label: String

    var body: some View {
        HStack {
            Text(label)
                .bold()
                .foregroundStyle(.white)
                .frame(width: 60)
            HStack {
                ForEach(items, id: \.self) { item in
                    itemButton(item)
                }
            }
            .padding(4)
            .background(.white.opacity(0.1), in: Capsule())
        }
        .padding(.horizontal)
    }

    private func itemButton(_ item: String) -> some View {
        Text(item)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .foregroundStyle(sel == item ? .white : .white.opacity(0.6))
            .background {
                if sel == item {
                    Capsule()
                        .fill(.white.opacity(0.2))
                        .matchedGeometryEffect(id: "selector", in: ns)
                }
            }
            .onTapGesture {
                withAnimation(.spring()) {
                    sel = item
                }
            }
    }
}
