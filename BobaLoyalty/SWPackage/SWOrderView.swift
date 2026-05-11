//
//  SWOrderView.swift
//  BobaLoyalty
//
//  ShipSwift Recipe: component-order-view（主组件）
//  奶茶定制核心交互：杯子 matchedGeometryEffect 多杯展开 + 渐变背景跟随颜色
//
//  BobaLoyalty 改造：
//  - flavor → sugar（糖度："无糖/三分糖/半糖/全糖"）
//  - size 保留（"中杯/大杯/超大"）
//  - SWCupView 把 ImageResource 换成 Color + SF Symbol 胶囊形占位
//    （主公后期可换成 Unsplash 实拍，只需替换 SWCupView body 即可）
//

import SwiftUI

// MARK: - SWOrderView

struct SWOrderView: View {
    /// 顶部展示用的杯色（由调用方注入：菜单选商品时已知 product.imageName）
    var cupColorName: String = "Drink_NaiCha"
    /// 杯壁/背景渐变的 baseColor（驱动整个页面氛围色，跟随商品色）
    var accentColor: Color = Color("BobaCaramel")

    @Binding var qty: Int
    @Binding var sugar: String
    @Binding var size: String

    var sugarOptions: [String] = ["无糖", "三分糖", "半糖", "全糖"]
    var sizeOptions: [String] = ["中杯", "大杯", "超大"]

    @Namespace private var sizeNS
    @Namespace private var sugarNS

    var body: some View {
        ZStack {
            backgroundGradient
            contentView
        }
    }

    private var backgroundGradient: some View {
        LinearGradient(
            colors: [.black, accentColor],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
        .animation(.easeInOut, value: accentColor)
    }

    private var contentView: some View {
        VStack(spacing: 24) {
            cupsSection
            quantityControl
            selectorsSection
            Spacer(minLength: 0)
        }
    }

    private var cupsSection: some View {
        ZStack {
            ForEach(Array(0..<qty), id: \.self) { i in
                SWCupView(
                    idx: i,
                    count: qty,
                    cupColorName: cupColorName,
                    size: size
                )
            }
        }
        .frame(height: 380)
        .animation(.spring(), value: qty)
    }

    private var quantityControl: some View {
        SWQuantityControl(qty: $qty)
    }

    private var selectorsSection: some View {
        VStack(spacing: 16) {
            SWOrderSelector(items: sizeOptions, sel: $size, ns: sizeNS, label: "杯型")
            SWOrderSelector(items: sugarOptions, sel: $sugar, ns: sugarNS, label: "糖度")
        }
    }
}

// MARK: - SWCupView（奶茶胶囊形占位）

/// 杯子视图：用 Color + SF Symbol 做"胶囊杯子"占位，未来可换成 Image
struct SWCupView: View {
    let idx: Int
    let count: Int
    let cupColorName: String
    let size: String

    private var cupHeight: CGFloat {
        switch size {
        case "大杯":   return 280
        case "超大":   return 320
        default:      return 240
        }
    }

    private var cupWidth: CGFloat {
        cupHeight * 0.5
    }

    private var isSide: Bool {
        count == 2 || (count >= 3 && idx != 1)
    }

    private var xOffset: CGFloat {
        switch count {
        case 2:  return idx == 0 ? -60 : 60
        case 3:  return idx == 0 ? -80 : idx == 2 ? 80 : 0
        default: return 0
        }
    }

    var body: some View {
        cupShape
            .frame(width: cupWidth, height: cupHeight)
            .scaleEffect(isSide ? 0.75 : 1.0)
            .offset(x: xOffset)
            .zIndex(count == 3 && idx == 1 ? 10 : Double(idx))
            .shadow(color: .black.opacity(0.3), radius: 15, y: 10)
            .animation(.easeInOut, value: cupColorName)
            .animation(.easeInOut, value: size)
            .transition(.asymmetric(
                insertion: .scale(scale: 0.1).combined(with: .opacity),
                removal: .opacity
            ))
    }

    /// 胶囊形杯子：上盖（深色）+ 杯身（商品色）+ 杯口图标
    private var cupShape: some View {
        VStack(spacing: 0) {
            // 杯盖
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .fill(Color.black.opacity(0.55))
                .frame(height: 14)
                .padding(.horizontal, -6)

            // 杯身：Capsule 形状装真照片，保留 matchedGeometryEffect 动画
            Capsule(style: .continuous)
                .fill(Color(cupColorName))
                .overlay(
                    Image(cupColorName)
                        .resizable()
                        .scaledToFill()
                        .clipShape(Capsule(style: .continuous))
                )
                .overlay(
                    Capsule(style: .continuous)
                        .strokeBorder(.white.opacity(0.35), lineWidth: 1.5)
                )
        }
    }
}

// MARK: - SWOrderButton（顶部圆形按钮，菜单页可选用）

struct SWOrderButton: View {
    let icon: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .frame(width: 44, height: 44)
                .background(.white.opacity(0.2), in: Circle())
        }
    }
}
