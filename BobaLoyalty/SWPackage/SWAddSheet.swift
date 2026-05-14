//
//  SWAddSheet.swift
//  BobaLoyalty
//
//  ShipSwift Recipe: component-add-sheet.
//  A medium-detent bottom sheet with a text input plus Cancel / Confirm buttons.
//  Used by the owner-side settings to enter the face value when broadcasting a promo
//  coupon (and works for any short-text input scenario).
//

import SwiftUI

struct SWAddSheet: View {
    @Binding var isPresented: Bool
    @State private var inputText = ""

    var title: LocalizedStringKey = "Enter text"
    var placeHolderText: LocalizedStringKey = "Type here..."
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
                    Text("Cancel")
                }
                .buttonStyle(.bordered)

                Button {
                    onConfirm?(inputText)
                    isPresented = false
                } label: {
                    Text("Confirm")
                }
                .buttonStyle(.borderedProminent)
                .disabled(inputText.isEmpty)
            }
            .padding()
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }

    // MARK: - Private input field

    private struct InputField: View {
        @Binding var text: String
        var placeHolderText: LocalizedStringKey = "Type a message..."
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
