//
//  SWQuantityControl.swift
//  BobaLoyalty
//
//  ShipSwift Recipe: component-order-view (QuantityControl subcomponent).
//  Oversized +/- stepper: white ultraThinMaterial circular buttons + numericText number transitions.
//  Capped at 3 cups (matches the multi-cup layout in SWCupView).
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
