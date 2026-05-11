//
//  SWSearchBar.swift
//  BobaLoyalty
//
//  ShipSwift Recipe: component-search-bar
//  胶囊形搜索框：放大镜图标 + 输入框 + 一键清空按钮，背景使用 .ultraThinMaterial。
//  本组件不带外部 horizontal padding，调用方自行 .padding(.horizontal) 控制布局。
//

import SwiftUI

struct SWSearchBar: View {
    /// 双向绑定当前搜索文本
    @Binding var text: String
    /// 输入框为空时的占位文案
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
