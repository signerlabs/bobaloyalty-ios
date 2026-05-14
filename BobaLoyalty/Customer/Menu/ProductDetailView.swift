//
//  ProductDetailView.swift
//  BobaLoyalty
//
//  Product detail / customize-and-order page, adapted from ShipSwift Recipe `component-order-view`:
//  - SWOrderView: matchedGeometryEffect multi-cup expansion + gradient background tracking the drink color
//  - Top add-on chips (coconut jelly +2 / pearls +3 / pudding +4 / oats +2 / taro balls +4)
//  - Bottom "Add to cart ¥XX" button → writes a CartItem to SwiftData + shows an SWAlert toast
//
//  Demo-video highlight: the 1 → 2 → 3 cup spring expansion + background gradient shifting on sugar change.
//

import SwiftUI
import SwiftData

struct ProductDetailView: View {
    let product: Product

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var qty: Int = 1
    @State private var selectedSize: String = "Medium"
    @State private var selectedSugar: String = "Half Sweet"
    @State private var selectedAddons: Set<String> = []

    /// Add-on options (name + extra price)
    private let addonOptions: [(String, Double)] = [
        ("Coconut Jelly", 2),
        ("Tapioca", 3),
        ("Pudding", 4),
        ("Oats", 2),
        ("Taro Ball", 4)
    ]

    /// Unit price for the currently selected size (large +3, extra-large +6)
    private var unitPrice: Double {
        let sizeUp: Double = {
            switch selectedSize {
            case "Large":   return 3
            case "XL":      return 6
            default:        return 0
            }
        }()
        let addonUp = addonOptions
            .filter { selectedAddons.contains($0.0) }
            .reduce(0.0) { $0 + $1.1 }
        return product.price + sizeUp + addonUp
    }

    /// Total = unit price × quantity
    private var totalPrice: Double {
        unitPrice * Double(qty)
    }

    /// Drink color (used as the base color for the background gradient)
    private var accentColor: Color {
        Color(product.imageName)
    }

    var body: some View {
        VStack(spacing: 0) {
            SWOrderView(
                cupColorName: product.imageName,
                accentColor: accentColor,
                qty: $qty,
                sugar: $selectedSugar,
                size: $selectedSize,
                sugarOptions: product.availableSugar.isEmpty ? ["No Sugar", "30% Sweet", "Half Sweet", "Full Sweet"] : product.availableSugar,
                sizeOptions: product.availableSizes.isEmpty ? ["Medium", "Large", "XL"] : product.availableSizes
            )
            .frame(maxHeight: .infinity)
            .overlay(alignment: .top) {
                topInfoBar
            }

            addonsSection
            addToCartButton
        }
        .background(accentColor.ignoresSafeArea())
        .navigationBarBackButtonHidden(false)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(product.name)
                    .font(.headline)
                    .foregroundStyle(.white)
            }
        }
    }

    // MARK: - Top info bar (product name + unit price)

    private var topInfoBar: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(product.name)
                    .font(.title3.bold())
                    .foregroundStyle(.white)
                Text(product.categoryName)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.7))
            }
            Spacer()

            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text("¥")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.85))
                Text("\(Int(unitPrice))")
                    .font(.title2.bold())
                    .foregroundStyle(.white)
                    .contentTransition(.numericText())
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 8)
    }

    // MARK: - Add-on chips

    private var addonsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Add-ons")
                .font(.subheadline.bold())
                .foregroundStyle(.white.opacity(0.9))
                .padding(.horizontal, 20)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(addonOptions, id: \.0) { addon in
                        addonChip(name: addon.0, price: addon.1)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.black.opacity(0.2))
    }

    @ViewBuilder
    private func addonChip(name: String, price: Double) -> some View {
        let isOn = selectedAddons.contains(name)
        Button {
            withAnimation(.spring(duration: 0.25)) {
                if isOn {
                    selectedAddons.remove(name)
                } else {
                    selectedAddons.insert(name)
                }
            }
        } label: {
            HStack(spacing: 4) {
                Text(name)
                Text("+\(Int(price))")
                    .font(.caption)
                    .foregroundStyle(isOn ? .white.opacity(0.85) : .white.opacity(0.55))
            }
            .font(.subheadline)
            .foregroundStyle(.white)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                Capsule().fill(isOn ? .white.opacity(0.3) : .white.opacity(0.1))
            )
            .overlay(
                Capsule().strokeBorder(.white.opacity(isOn ? 0.6 : 0.15), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.selection, trigger: isOn)
    }

    // MARK: - Add-to-cart button

    private var addToCartButton: some View {
        Button {
            addToCart()
        } label: {
            HStack {
                Image(systemName: "bag.badge.plus")
                Text("Add to Cart ¥\(Int(totalPrice))")
                    .contentTransition(.numericText())
            }
            .font(.title3.bold())
            .frame(maxWidth: .infinity, minHeight: 56)
            .background(.white)
            .foregroundStyle(accentColor)
            .clipShape(Capsule())
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .buttonStyle(.plain)
        .background(.black.opacity(0.2))
    }

    // MARK: - Add-to-cart logic

    private func addToCart() {
        let item = CartItem(
            product: product,
            size: selectedSize,
            sugar: selectedSugar,
            addons: Array(selectedAddons),
            quantity: qty,
            unitPrice: unitPrice
        )
        modelContext.insert(item)
        SWAlertManager.shared.show(.success, message: "Added to cart")

        // After adding, dismiss back to the menu so the user can keep browsing
        dismiss()
    }
}

#Preview {
    NavigationStack {
        ProductDetailView(
            product: Product(
                name: "Signature Milk Tea",
                categoryName: "Signature",
                price: 16,
                imageName: "Drink_NaiCha",
                isOnSale: true
            )
        )
    }
    .modelContainer(for: [
        Product.self, CartItem.self, Order.self, Customer.self, Coupon.self
    ], inMemory: true)
}
