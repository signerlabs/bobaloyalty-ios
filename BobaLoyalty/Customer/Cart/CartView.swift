//
//  CartView.swift
//  BobaLoyalty
//
//  Customer-side cart: lists `@Query var cartItems` with swipe-to-delete and
//  SWStepper-based quantity adjustment. A pinned bottom bar shows the total
//  amount plus a "Checkout" button that pushes CheckoutView.
//

import SwiftUI
import SwiftData

struct CartView: View {
    @Query(sort: \CartItem.addedAt, order: .reverse) private var cartItems: [CartItem]
    @Environment(\.modelContext) private var modelContext

    /// Cart total
    private var totalAmount: Double {
        cartItems.reduce(0.0) { $0 + $1.lineTotal }
    }

    /// Total cup count
    private var totalCups: Int {
        cartItems.reduce(0) { $0 + $1.quantity }
    }

    var body: some View {
        Group {
            if cartItems.isEmpty {
                emptyState
            } else {
                cartList
            }
        }
        .background(Color("BobaPearl").ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("购物车")
                    .font(.headline)
                    .foregroundStyle(Color("BobaBrown"))
            }
        }
        .safeAreaInset(edge: .bottom) {
            if !cartItems.isEmpty {
                checkoutBar
            }
        }
    }

    // MARK: - Empty state

    private var emptyState: some View {
        ContentUnavailableView {
            Label("购物车空空如也", systemImage: "bag")
        } description: {
            Text("去菜单看看，挑一杯喜欢的奶茶吧")
        }
    }

    // MARK: - List

    private var cartList: some View {
        List {
            ForEach(cartItems) { item in
                CartRow(item: item)
                    .listRowBackground(Color.white)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
            }
            .onDelete(perform: deleteItems)
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }

    // MARK: - Bottom checkout bar

    private var checkoutBar: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text("合计")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text("¥")
                        .font(.subheadline)
                        .foregroundStyle(Color("BobaCaramel"))
                    Text("\(String(format: "%.0f", totalAmount))")
                        .font(.title2.bold())
                        .foregroundStyle(Color("BobaCaramel"))
                        .contentTransition(.numericText())
                }
            }

            Spacer()

            NavigationLink {
                CheckoutView()
            } label: {
                Text("去结算 · \(totalCups) 杯")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 14)
                    .background(Color("BobaCaramel"), in: Capsule())
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial)
    }

    // MARK: - Delete

    private func deleteItems(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(cartItems[index])
        }
        SWAlertManager.shared.show(.info, message: "已移除")
    }
}

// MARK: - Cart row

private struct CartRow: View {
    @Bindable var item: CartItem

    private var displayName: String {
        item.product?.name ?? "已下架商品"
    }

    private var displayImage: String {
        item.product?.imageName ?? "Drink_NaiCha"
    }

    private var addonsText: String? {
        item.addons.isEmpty ? nil : item.addons.joined(separator: " · ")
    }

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            DrinkThumbnail(imageName: displayImage, size: 72, cornerRadius: 14)

            VStack(alignment: .leading, spacing: 6) {
                Text(displayName)
                    .font(.subheadline.bold())
                    .foregroundStyle(Color("BobaBrown"))

                HStack(spacing: 6) {
                    specChip(item.size)
                    specChip(item.sugar)
                }

                if let addons = addonsText {
                    Text(addons)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                HStack {
                    HStack(alignment: .firstTextBaseline, spacing: 2) {
                        Text("¥")
                            .font(.caption)
                            .foregroundStyle(Color("BobaCaramel"))
                        Text("\(String(format: "%.0f", item.unitPrice))")
                            .font(.subheadline.bold())
                            .foregroundStyle(Color("BobaCaramel"))
                    }
                    Spacer()
                    SWStepper(quantity: $item.quantity)
                        .foregroundStyle(Color("BobaBrown"))
                }
                .padding(.top, 4)
            }
        }
        .padding(12)
        .background(Color.white, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(Color("BobaCream"), lineWidth: 1)
        )
    }

    private func specChip(_ text: String) -> some View {
        Text(text)
            .font(.caption2)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(Color("BobaCream"), in: Capsule())
            .foregroundStyle(Color("BobaBrown"))
    }
}

#Preview {
    NavigationStack {
        CartView()
    }
    .modelContainer(for: [
        Product.self, CartItem.self, Order.self, Customer.self, Coupon.self
    ], inMemory: true)
}
