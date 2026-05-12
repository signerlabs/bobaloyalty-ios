//
//  SWSearchBar.swift
//  BobaLoyalty
//
//  ShipSwift Recipe: component-search-bar.
//  Capsule-shaped search field: magnifier icon + text input + clear button, backed by .ultraThinMaterial.
//  Does not apply outer horizontal padding; callers should `.padding(.horizontal)` to control layout.
//

import SwiftUI

struct SWSearchBar: View {
    /// Two-way binding to the current search text
    @Binding var text: String
    /// Placeholder text when the input is empty
    var placeholder: String = "搜索"

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)

            TextField(placeholder, text: $text)
                .autocorrectionDisabled()

            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
        }
        .font(.system(size: 14))
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(.ultraThinMaterial, in: .capsule)
    }
}
