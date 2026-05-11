//
//  SWQuantityControl.swift
//  BobaLoyalty
//
//  ShipSwift Recipe: component-order-view（QuantityControl 子组件）
//  超大尺寸 +/- 步进器：白色 ultraThinMaterial 圆形按钮 + numericText 数字过渡
//  最大 3 杯（与 SWCupView 多杯布局对齐）
//

import SwiftUI

struct SWQuantityControl: View {
    @Binding var qty: Int
    var maxQty: Int = 3

    var body: some View {
        HStack(spacing: 40) {
            Button { if qty > 1 { qty -= 1 } } label: {
                Image(systemName: "minus.circle.fill")
                    .font(.largeTitle)
                    .foregroundStyle(.white, .ultraThinMaterial)
            }

            Text("\(qty)")
                .font(.system(size: 40, weight: .black))
                .contentTransition(.numericText())
                .frame(width: 60)

            Button { if qty < maxQty { qty += 1 } } label: {
                Image(systemName: "plus.circle.fill")
                    .font(.largeTitle)
                    .foregroundStyle(.white, .ultraThinMaterial)
            }
        }
        .foregroundStyle(Color.white)
    }
}
