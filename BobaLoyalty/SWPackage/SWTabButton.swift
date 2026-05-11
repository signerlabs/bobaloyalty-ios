//
//  SWTabButton.swift
//  BobaLoyalty
//
//  ShipSwift Recipe: component-tab-button
//  胶囊形 Tab 按钮：选中（accent 色）/ 未选中（灰色）切换
//  适合做横向分类筛选条 / 自定义 segmented control
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
