//
//  DrinkThumbnail.swift
//  BobaLoyalty
//
//  奶茶缩略图：Assets/Drinks/ 下的真实照片（Unsplash CC0 免费可商用）
//  全 App 通用：菜单卡 / 购物车行 / 订单记录 / 详情页缩略图
//
//  ImageSet 与同名 ColorSet（DrinkColors/）共存：
//  - Image(imageName) 拿照片
//  - Color(imageName) 拿底色，作为图片加载前/失败时的兜底
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
