//
//  ProductDetailView.swift
//  BobaLoyalty
//
//  商品详情 / 定制下单页：基于 ShipSwift Recipe `component-order-view` 改造
//  - SWOrderView：杯子 matchedGeometryEffect 多杯展开 + 渐变背景跟随商品色
//  - 顶部加料 chips（椰果 +2 / 珍珠 +3 / 布丁 +4 / 燕麦 +2 / 芋圆 +4）
//  - 底部"加入购物车 ¥XX"按钮 → 写 CartItem 到 SwiftData + SWAlert 提示
//
//  视频炸场点：杯子从 1 → 2 → 3 杯的 spring 展开动画 + 切换糖度时背景渐变
//

import SwiftUI
import SwiftData

struct ProductDetailView: View {
    let product: Product

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var qty: Int = 1
    @State private var selectedSize: String = "中杯"
    @State private var selectedSugar: String = "五分糖"
    @State private var selectedAddons: Set<String> = []

    /// 加料选项（名称 + 加价）
    private let addonOptions: [(String, Double)] = [
        ("椰果", 2),
        ("珍珠", 3),
        ("布丁", 4),
        ("燕麦", 2),
        ("芋圆", 4)
    ]

    /// 当前规格的单价（大杯 +3，超大 +6）
    private var unitPrice: Double {
        let sizeUp: Double = {
            switch selectedSize {
            case "大杯":   return 3
            case "超大":   return 6
            default:      return 0
            }
        }()
        let addonUp = addonOptions
            .filter { selectedAddons.contains($0.0) }
            .reduce(0.0) { $0 + $1.1 }
        return product.price + sizeUp + addonUp
    }

    /// 总价 = 单价 × 数量
    private var totalPrice: Double {
        unitPrice * Double(qty)
    }

    /// 商品色（用于背景渐变 baseColor）
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
                sugarOptions: product.availableSugar.isEmpty ? ["无糖", "三分糖", "半糖", "全糖"] : product.availableSugar,
                sizeOptions: product.availableSizes.isEmpty ? ["中杯", "大杯", "超大"] : product.availableSizes
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

    // MARK: - 顶部信息条（商品名 + 单价）

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

    // MARK: - 加料 chips

    private var addonsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("加料")
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

    // MARK: - 加入购物车按钮

    private var addToCartButton: some View {
        Button {
            addToCart()
        } label: {
            HStack {
                Image(systemName: "bag.badge.plus")
                Text("加入购物车 ¥\(Int(totalPrice))")
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

    // MARK: - 加购逻辑

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
        SWAlertManager.shared.show(.success, message: "已加入购物车")

        // 加完返回菜单，继续浏览
        dismiss()
    }
}

#Preview {
    NavigationStack {
        ProductDetailView(
            product: Product(
                name: "招牌奶茶",
                categoryName: "招牌",
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
