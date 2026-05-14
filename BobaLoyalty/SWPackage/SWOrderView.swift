//
//  SWOrderView.swift
//  BobaLoyalty
//
//  ShipSwift Recipe: component-order-view (main component).
//  Core drink-customization interaction: cups expand/contract with matchedGeometryEffect
//  and the gradient background follows the drink color.
//
//  BobaLoyalty adaptations:
//  - flavor → sugar (sugar level: zero / 30% / half / full)
//  - size kept (medium / large / extra-large)
//  - SWCupView replaces ImageResource with a Color + SF Symbol capsule placeholder
//    (later, swap to real photos by replacing the body of SWCupView)
//

import SwiftUI

// MARK: - SWOrderView

struct SWOrderView: View {
    /// Cup color displayed at the top (injected by the caller; the menu already knows `product.imageName`)
    var cupColorName: String = "Drink_NaiCha"
    /// Base color for cup walls / background gradient (drives the whole page accent, following the drink color)
    var accentColor: Color = Color("BobaCaramel")

    @Binding var qty: Int
    @Binding var sugar: String
    @Binding var size: String

    var sugarOptions: [String] = ["No Sugar", "30% Sweet", "Half Sweet", "Full Sweet"]
    var sizeOptions: [String] = ["Medium", "Large", "XL"]

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
            SWOrderSelector(items: sizeOptions, sel: $size, ns: sizeNS, label: "Size")
            SWOrderSelector(items: sugarOptions, sel: $sugar, ns: sugarNS, label: "Sugar")
        }
    }
}

// MARK: - SWCupView (capsule-shaped drink placeholder)

/// Cup view: uses Color + SF Symbol to draw a "capsule cup" placeholder; can later be swapped for an Image
struct SWCupView: View {
    let idx: Int
    let count: Int
    let cupColorName: String
    let size: String

    private var cupHeight: CGFloat {
        switch size {
        case "Large":   return 280
        case "XL":      return 320
        default:        return 240
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

    /// Capsule cup: lid (dark) + body (drink color) + mouth icon
    private var cupShape: some View {
        VStack(spacing: 0) {
            // Lid
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .fill(Color.black.opacity(0.55))
                .frame(height: 14)
                .padding(.horizontal, -6)

            // Body: a Capsule clip that holds the real photo while preserving the matchedGeometryEffect animation
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

// MARK: - SWOrderButton (top circular button, optional for use on the menu page)

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
