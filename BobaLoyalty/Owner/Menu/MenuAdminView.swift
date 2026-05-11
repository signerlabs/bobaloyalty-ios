//
//  MenuAdminView.swift
//  BobaLoyalty
//
//  老板端 Tab 2：菜单管理
//  - 顶部 SWSearchBar 搜索（按商品名）
//  - 商品列表：thumbnail + 名称 + 价格 + 上下架开关
//  - 右上 "+" 新增；点击行编辑；左滑删除（带二次确认）
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

    // MARK: - 过滤

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
            // 搜索栏
            SWSearchBar(text: $searchText, placeholder: "搜索商品名 / 分类")
                .padding(.horizontal)
                .padding(.top, 8)
                .padding(.bottom, 6)

            // 列表
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
                                Label("删除", systemImage: "trash")
                            }
                        }
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
        }
        .background(Color("BobaCream").ignoresSafeArea())
        .navigationTitle("菜单管理")
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
        // 新增 sheet
        .sheet(isPresented: $showingNewSheet) {
            ProductEditView(existing: nil)
        }
        // 编辑 sheet
        .sheet(item: $editingProduct) { product in
            ProductEditView(existing: product)
        }
        // 删除二次确认
        .alert("删除商品", isPresented: Binding(
            get: { pendingDelete != nil },
            set: { if !$0 { pendingDelete = nil } }
        )) {
            Button("取消", role: .cancel) { pendingDelete = nil }
            Button("删除", role: .destructive) {
                if let p = pendingDelete {
                    modelContext.delete(p)
                    SWAlertManager.shared.show(.success, message: "已删除「\(p.name)」")
                }
                pendingDelete = nil
            }
        } message: {
            if let p = pendingDelete {
                Text("确认删除「\(p.name)」？此操作不可撤销。")
            }
        }
    }

    // MARK: - 单行

    @ViewBuilder
    private func productRow(_ product: Product) -> some View {
        HStack(spacing: 12) {
            // 圆形占位色 + SF Symbol
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
                        Text("热卖")
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

            // 上架开关：直接绑定 SwiftData 字段，autosave 生效
            Toggle("上架", isOn: Binding(
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
