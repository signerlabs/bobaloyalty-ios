//
//  SWAddSheet.swift
//  BobaLoyalty
//
//  ShipSwift Recipe: component-add-sheet
//  底部 medium detent sheet，带文本输入 + 取消/继续按钮。
//  在老板设置里用于"群发促销券"输入券面额（也可输入任意短文本场景）。
//

import SwiftUI

struct SWAddSheet: View {
    @Binding var isPresented: Bool
    @State private var inputText = ""

    var title: LocalizedStringKey = "请输入"
    var placeHolderText: LocalizedStringKey = "在此输入..."
    var minLines: Int = 5
    var onConfirm: ((String) -> Void)?

    var body: some View {
        VStack {
            Text(title)
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .padding(.horizontal)

            InputField(
                text: $inputText,
                placeHolderText: placeHolderText,
                minLines: minLines
            )

            Spacer()
            Spacer()

            HStack {
                Button {
                    isPresented = false
                } label: {
                    Text("取消")
                }
                .buttonStyle(.bordered)

                Button {
                    onConfirm?(inputText)
                    isPresented = false
                } label: {
                    Text("确认")
                }
                .buttonStyle(.borderedProminent)
                .disabled(inputText.isEmpty)
            }
            .padding()
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }

    // MARK: - 私有输入框

    private struct InputField: View {
        @Binding var text: String
        var placeHolderText: LocalizedStringKey = "输入消息..."
        var minLines: Int = 1

        @FocusState private var isFocused: Bool

        var body: some View {
            TextField(placeHolderText, text: $text, axis: .vertical)
                .lineLimit(minLines...5)
                .focused($isFocused)
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(.primary, lineWidth: 1)
                )
                .padding(.horizontal)
                .padding(.vertical, 8)
        }
    }
}
