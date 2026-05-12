//
//  DrinkThumbnail.swift
//  BobaLoyalty
//
//  Drink thumbnail: real photos under Assets/Drinks/ (Unsplash CC0, free for commercial use).
//  Shared across the App: menu cards, cart rows, order history rows, detail-page thumbnails.
//
//  An ImageSet and a same-named ColorSet (DrinkColors/) coexist:
//  - `Image(imageName)` returns the photo
//  - `Color(imageName)` returns the base color, used as a fallback before / if the image fails to load
//

import SwiftUI

struct DrinkThumbnail: View {
    let imageName: String
    var size: CGFloat = 120
    var cornerRadius: CGFloat = 18

    var body: some View {
        Color(imageName)
            .overlay(
                Image(imageName)
                    .resizable()
                    .scaledToFill()
            )
            .frame(width: size, height: size)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(.white.opacity(0.18), lineWidth: 1)
            )
    }
}

#Preview {
    VStack(spacing: 16) {
        DrinkThumbnail(imageName: "Drink_NaiCha")
        DrinkThumbnail(imageName: "Drink_YangZhi", size: 80)
        DrinkThumbnail(imageName: "Drink_KaoNai", size: 60, cornerRadius: 12)
    }
    .padding()
}
