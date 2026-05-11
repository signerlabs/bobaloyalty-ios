//
//  SWStepper.swift
//  BobaLoyalty
//
//  ShipSwift Recipe: component-stepper
//  紧凑型数量步进器：左右 chevron + 数字 contentTransition + 触觉反馈
//  数量 = 0 时减号自动 disabled
//

import SwiftUI

struct SWStepper: View {
    @Binding var quantity: Int

    var body: some View {
        HStack {
            Button {
                quantity -= 1
            } label: {
                Image(systemName: "chevron.backward")
                    .imageScale(.large)
            }
            .disabled(quantity <= 0)
            .buttonStyle(.plain)

            Text("\(quantity)")
                .frame(minWidth: 26)
                .contentTransition(.numericText())

            Button {
                quantity += 1
            } label: {
                Image(systemName: "chevron.forward")
                    .imageScale(.large)
            }
            .buttonStyle(.plain)
        }
        .animation(.default, value: quantity)
        .sensoryFeedback(.increase, trigger: [quantity])
    }
}
