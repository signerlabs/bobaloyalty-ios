//
//  MenuAdminView.swift
//  BobaLoyalty
//
//  Owner-side Tab 2: menu admin.
//  - Top SWSearchBar (searches by product name)
//  - Product list: thumbnail + name + price + listing toggle
//  - Top-right "+" creates a new product; tap a row to edit; swipe-to-delete with a confirmation
//

import SwiftUI
import SwiftData

struct MenuAdminView: View {
    @Environment(\.modelContext) private var modelContext

    @Query(sort: \Product.createdAt, order: .reverse)
    private var products: [Product]

    @State private var searchText: String = ""
    @State private var showingNewSheet = false
    @State private var editingProduct: Product?
    @State private var pendingDelete: Product?

    // MARK: - Filtering

    private var filteredProducts: [Product] {
        let trimmed = searchText.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return products }
        return products.filter {
            $0.name.localizedCaseInsensitiveContains(trimmed)
                || $0.categoryName.localizedCaseInsensitiveContains(trimmed)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Search bar
            SWSearchBar(text: $searchText, placeholder: "Search name / category")
                .padding(.horizontal)
                .padding(.top, 8)
                .padding(.bottom, 6)

            // List
            List {
                ForEach(filteredProducts) { product in
                    productRow(product)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            editingProduct = product
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button(role: .destructive) {
                                pendingDelete = product
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
        }
        .background(Color("BobaCream").ignoresSafeArea())
        .navigationTitle("Menu Admin")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingNewSheet = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                        .foregroundStyle(Color("BobaCaramel"))
                }
            }
        }
        // Create sheet
        .sheet(isPresented: $showingNewSheet) {
            ProductEditView(existing: nil)
        }
        // Edit sheet
        .sheet(item: $editingProduct) { product in
            ProductEditView(existing: product)
        }
        // Delete confirmation
        .alert("Delete product", isPresented: Binding(
            get: { pendingDelete != nil },
            set: { if !$0 { pendingDelete = nil } }
        )) {
            Button("Cancel", role: .cancel) { pendingDelete = nil }
            Button("Delete", role: .destructive) {
                if let p = pendingDelete {
                    modelContext.delete(p)
                    SWAlertManager.shared.show(.success, message: "Deleted \"\(p.name)\"")
                }
                pendingDelete = nil
            }
        } message: {
            if let p = pendingDelete {
                Text("Delete \"\(p.name)\"? This cannot be undone.")
            }
        }
    }

    // MARK: - Single row

    @ViewBuilder
    private func productRow(_ product: Product) -> some View {
        HStack(spacing: 12) {
            // Circular color placeholder + SF Symbol
            ZStack {
                Circle()
                    .fill(Color(product.imageName))
                    .frame(width: 48, height: 48)
                Image(systemName: "cup.and.saucer.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(.white.opacity(0.85))
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(product.name)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    if product.isOnSale {
                        Text("Hot")
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Capsule().fill(Color("BobaPink").opacity(0.6)))
                            .foregroundStyle(.white)
                    }
                }
                Text(product.categoryName)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text("¥\(product.price, specifier: "%.0f")")
                    .font(.subheadline)
                    .foregroundStyle(Color("BobaCaramel"))
            }

            Spacer()

            // Listing toggle: binds directly to the SwiftData field so autosave kicks in
            Toggle("List", isOn: Binding(
                get: { product.isOnSale },
                set: { product.isOnSale = $0 }
            ))
            .labelsHidden()
            .tint(Color("BobaMatcha"))
        }
        .padding(.vertical, 4)
        .listRowBackground(Color(.systemBackground))
        .listRowSeparator(.hidden)
        .listRowInsets(EdgeInsets(top: 6, leading: 12, bottom: 6, trailing: 12))
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(.systemBackground))
        )
    }
}

#Preview("Seeded") {
    NavigationStack {
        MenuAdminView()
    }
    .modelContainer(MockSeed.previewContainer)
}
