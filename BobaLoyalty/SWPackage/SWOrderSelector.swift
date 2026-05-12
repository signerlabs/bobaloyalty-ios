//
//  SWOrderSelector.swift
//  BobaLoyalty
//
//  ShipSwift Recipe: component-order-view (Selector subcomponent).
//  Capsule-shaped option switcher; matchedGeometryEffect slides the selection
//  seamlessly between options. Used in BobaLoyalty for switching size / sugar level.
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
