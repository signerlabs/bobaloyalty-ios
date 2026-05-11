//
//  MenuView.swift
//  BobaLoyalty
//
//  顾客端菜单页：品牌 header + 横向分类切换（SWTabButton）+ 商品 LazyVGrid 2 列网格
//  数据源：@Query var products: [Product] 直接读 SwiftData
//  点击商品 push 到 ProductDetailView
//

import SwiftUI
import SwiftData

struct MenuView: View {
    @Query(sort: \Product.createdAt) private var products: [Product]
    @State private var selectedCategory: String = "全部"

    /// 自动从商品中聚合分类（"全部" + 出现的分类去重保序）
    private var categories: [String] {
        var ordered: [String] = []
        for p in products where !ordered.contains(p.categoryName) {
            ordered.append(p.categoryName)
        }
        return ["全部"] + ordered
    }

    /// 当前分类下的商品
    private var filteredProducts: [Product] {
        if selectedCategory == "全部" {
            return products
        }
        return products.filter { $0.categoryName == selectedCategory }
    }

    private let columns = [
        GridItem(.flexible(), spacing: 14),
        GridItem(.flexible(), spacing: 14)
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                brandHeader
                categoryBar
                productGrid
            }
        }
        .background(Color("BobaPearl").ignoresSafeArea())
        .scrollIndicators(.hidden)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("微茶 WeiBoba")
                    .font(.headline)
                    .foregroundStyle(Color("BobaBrown"))
            }
        }
    }

    // MARK: - 品牌 Header

    private var brandHeader: some View {
        ZStack(alignment: .bottomLeading) {
            LinearGradient(
                colors: [Color("BobaCream"), Color("BobaCaramel").opacity(0.8)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            HStack(alignment: .bottom) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("今日热卖")
                        .font(.caption)
                        .foregroundStyle(Color("BobaBrown").opacity(0.7))
                    Text("一杯奶茶 一份心意")
                        .font(.title2.bold())
                        .foregroundStyle(Color("BobaBrown"))
                }
                Spacer()

                Image(systemName: "cup.and.saucer.fill")
                    .font(.system(size: 56, weight: .light))
                    .foregroundStyle(Color("BobaBrown").opacity(0.55))
            }
            .padding(20)
        }
        .frame(height: 140)
    }

    // MARK: - 分类切换条

    private var categoryBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(categories, id: \.self) { cat in
                    SWTabButton(
                        title: LocalizedStringKey(cat),
                        isSelected: cat == selectedCategory
                    ) {
                        withAnimation(.spring(duration: 0.3)) {
                            selectedCategory = cat
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
        }
        .background(Color("BobaPearl"))
    }

    // MARK: - 商品网格

    private var productGrid: some View {
        LazyVGrid(columns: columns, spacing: 14) {
            ForEach(filteredProducts) { product in
                NavigationLink {
                    ProductDetailView(product: product)
                } label: {
                    ProductCard(product: product)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 24)
    }
}

// MARK: - 商品卡片

private struct ProductCard: View {
    let product: Product

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 图片区：自适应卡片宽度的正方形，四周 12pt 内边距与卡片留白
            ZStack(alignment: .topLeading) {
                Color(product.imageName)
                    .overlay(
                        Image(product.imageName)
                            .resizable()
                            .scaledToFill()
                    )
                    .aspectRatio(1, contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

                if product.isOnSale {
                    Text("热卖")
                        .font(.caption2.bold())
                        .foregroundStyle(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color("BobaPink"), in: Capsule())
                        .padding(10)
                }
            }
            .padding(12)

            // 文字区：横向 16pt 与卡片留出对齐感，底部 14pt
            VStack(alignment: .leading, spacing: 6) {
                Text(product.name)
                    .font(.subheadline.bold())
                    .foregroundStyle(Color("BobaBrown"))
                    .lineLimit(1)

                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text("¥")
                        .font(.footnote)
                        .foregroundStyle(Color("BobaCaramel"))
                    Text("\(Int(product.price))")
                        .font(.title3.bold())
                        .foregroundStyle(Color("BobaCaramel"))
                    Text("起")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .padding(.leading, 2)
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 14)
        }
        .background(Color.white, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

#Preview {
    NavigationStack {
        MenuView()
    }
    .modelContainer(for: [
        Product.self, CartItem.self, Order.self, Customer.self, Coupon.self
    ], inMemory: true)
}
