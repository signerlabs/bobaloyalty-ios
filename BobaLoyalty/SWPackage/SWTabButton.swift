//
//  SWTabButton.swift
//  BobaLoyalty
//
//  ShipSwift Recipe: component-tab-button.
//  Capsule-shaped tab button that toggles between selected (accent color) and unselected (gray) states.
//  Great for horizontal category filter chips or a custom segmented control.
//

import SwiftUI

struct SWTabButton: View {
    let title: LocalizedStringKey
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.accentColor : Color.secondary.opacity(0.2))
                .foregroundStyle(isSelected ? .white : .primary)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}
