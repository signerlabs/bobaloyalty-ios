//
//  ProductEditView.swift
//  BobaLoyalty
//
//  Product-edit sheet, shared between create and edit modes.
//  - Name, price, category, color-chip placeholder picker
//  - Size / sugar checkboxes
//  - Listing (on-sale) toggle
//  - Save writes to SwiftData and shows an SWAlert toast
//

import SwiftUI
import SwiftData

struct ProductEditView: View {
    /// Edit mode: pass `existing`; create mode: pass nil
    let existing: Product?
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    // MARK: - Form fields

    @State private var name: String = ""
    @State private var priceText: String = ""
    @State private var category: String = "Milk Tea"
    @State private var imageName: String = "Drink_NaiCha"
    @State private var selectedSizes: Set<String> = ["Medium", "Large"]
    @State private var selectedSugar: Set<String> = ["No Sugar", "30% Sweet", "Half Sweet", "70% Sweet", "Full Sweet"]
    @State private var isOnSale: Bool = false

    // MARK: - Option constants

    private let categoryOptions = ["Signature", "Milk Tea", "Fruit Tea", "Latte", "Snacks"]
    private let sizeOptions = ["Small", "Medium", "Large", "XL"]
    private let sugarOptions = ["No Sugar", "30% Sweet", "Half Sweet", "70% Sweet", "Full Sweet"]

    /// 8 product-color placeholder chips
    private let imageOptions: [String] = [
        "Drink_NaiCha", "Drink_ZhenZhu", "Drink_MoCha", "Drink_MoLi",
        "Drink_YuYuan", "Drink_KaoNai", "Drink_YangZhi", "Drink_NingMeng"
    ]

    private var isEditing: Bool { existing != nil }
    private var titleText: String { isEditing ? "Edit Product" : "New Product" }

    /// Whether the form is valid
    private var canSubmit: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
            && Double(priceText) != nil
            && !selectedSizes.isEmpty
            && !selectedSugar.isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                // MARK: Basic info
                Section("Basics") {
                    TextField("Product name", text: $name)
                    HStack {
                        Text("Price")
                        TextField("0.00", text: $priceText)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                        Text("¥")
                            .foregroundStyle(.secondary)
                    }
                    Picker("Category", selection: $category) {
                        ForEach(categoryOptions, id: \.self) { Text($0) }
                    }
                    Toggle("Mark as hot", isOn: $isOnSale)
                }

                // MARK: Placeholder color
                Section("Color") {
                    LazyVGrid(
                        columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 4),
                        spacing: 14
                    ) {
                        ForEach(imageOptions, id: \.self) { name in
                            colorChip(name)
                        }
                    }
                    .padding(.vertical, 4)
                }

                // MARK: Available sizes
                Section("Sizes") {
                    ForEach(sizeOptions, id: \.self) { size in
                        toggleRow(text: size, isOn: Binding(
                            get: { selectedSizes.contains(size) },
                            set: { newValue in
                                if newValue { selectedSizes.insert(size) }
                                else { selectedSizes.remove(size) }
                            }
                        ))
                    }
                }

                // MARK: Sugar level
                Section("Sugar levels") {
                    ForEach(sugarOptions, id: \.self) { sugar in
                        toggleRow(text: sugar, isOn: Binding(
                            get: { selectedSugar.contains(sugar) },
                            set: { newValue in
                                if newValue { selectedSugar.insert(sugar) }
                                else { selectedSugar.remove(sugar) }
                            }
                        ))
                    }
                }
            }
            .navigationTitle(titleText)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(!canSubmit)
                }
            }
            .onAppear { loadInitialState() }
        }
    }

    // MARK: - Subviews

    private func colorChip(_ name: String) -> some View {
        let isSelected = imageName == name
        return Button {
            imageName = name
        } label: {
            ZStack {
                Circle()
                    .fill(Color(name))
                    .frame(width: 44, height: 44)
                if isSelected {
                    Circle()
                        .stroke(Color("BobaCaramel"), lineWidth: 3)
                        .frame(width: 50, height: 50)
                    Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.white)
                }
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }

    private func toggleRow(text: String, isOn: Binding<Bool>) -> some View {
        Toggle(isOn: isOn) {
            Text(text)
                .font(.subheadline)
        }
    }

    // MARK: - State loading

    private func loadInitialState() {
        guard let p = existing else { return }
        name = p.name
        priceText = String(format: "%g", p.price)
        category = p.categoryName
        imageName = p.imageName
        selectedSizes = Set(p.availableSizes)
        selectedSugar = Set(p.availableSugar)
        isOnSale = p.isOnSale
    }

    // MARK: - Save

    private func save() {
        guard let price = Double(priceText) else { return }
        let trimmedName = name.trimmingCharacters(in: .whitespaces)

        if let p = existing {
            // Edit existing product
            p.name = trimmedName
            p.price = price
            p.categoryName = category
            p.imageName = imageName
            p.availableSizes = Array(selectedSizes)
            p.availableSugar = Array(selectedSugar)
            p.isOnSale = isOnSale
            SWAlertManager.shared.show(.success, message: "Product updated")
        } else {
            // Create new product
            let new = Product(
                name: trimmedName,
                categoryName: category,
                price: price,
                imageName: imageName,
                availableSizes: Array(selectedSizes),
                availableSugar: Array(selectedSugar),
                isOnSale: isOnSale
            )
            modelContext.insert(new)
            SWAlertManager.shared.show(.success, message: "Product added")
        }
        dismiss()
    }
}

#Preview("New Product") {
    ProductEditView(existing: nil)
        .modelContainer(for: [
            Product.self, CartItem.self, Order.self, Customer.self, Coupon.self
        ], inMemory: true)
}

#Preview("Edit Product") {
    let sample = Product(
        name: "Signature Milk Tea",
        categoryName: "Signature",
        price: 16,
        imageName: "Drink_NaiCha",
        isOnSale: true
    )
    return ProductEditView(existing: sample)
        .modelContainer(for: [
            Product.self, CartItem.self, Order.self, Customer.self, Coupon.self
        ], inMemory: true)
}
