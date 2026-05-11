//
//  SWLoading.swift
//  BobaLoyalty
//
//  ShipSwift Recipe: component-loading
//  全屏 page-level loading：模糊背景 + 可选 SF Symbol 脉冲动效 + 可定制文案 + ProgressView
//  每个页面独立 loading 状态，通过 SWLoadingPage enum 隔离
//
//  BobaLoyalty 中已扩展 .checkout / .cart 两个页面 case
//

import SwiftUI

// MARK: - Page Loading State

/// 单页 loading 状态
struct SWPageLoadingState {
    var isShowing: Bool = false
    var message: String = "Loading..."
    var systemImage: String? = nil
}

// MARK: - Page Identifier

/// 页面标识 enum —— BobaLoyalty 用到的页面在此注册
enum SWLoadingPage: String {
    case home
    case settings
    case profile
    case checkout      // 结算页 mock 支付
    case cart          // 购物车
    case menu          // 菜单
}

// MARK: - SWLoadingManager

@MainActor
@Observable
final class SWLoadingManager {
    static let shared = SWLoadingManager()

    private var pageStates: [SWLoadingPage: SWPageLoadingState] = [:]

    private init() {}

    // MARK: - Page-level Loading

    /// 显示 page loading overlay
    func show(page: SWLoadingPage, message: String = "Loading...", systemImage: String? = nil) {
        pageStates[page] = SWPageLoadingState(isShowing: true, message: message, systemImage: systemImage)
    }

    /// 更新 loading 文案
    func updateMessage(page: SWLoadingPage, message: String) {
        pageStates[page]?.message = message
    }

    /// 隐藏 page loading overlay
    func hide(page: SWLoadingPage) {
        pageStates[page]?.isShowing = false
    }

    /// 取页面 loading 状态
    func state(for page: SWLoadingPage) -> SWPageLoadingState {
        pageStates[page] ?? SWPageLoadingState()
    }
}

// MARK: - Page Loading View

struct SWPageLoadingView: View {
    let page: SWLoadingPage

    private var state: SWPageLoadingState {
        SWLoadingManager.shared.state(for: page)
    }

    var body: some View {
        if state.isShowing {
            VStack(spacing: 24) {
                if let systemImage = state.systemImage {
                    Image(systemName: systemImage)
                        .font(.system(size: 64, weight: .light))
                        .foregroundStyle(.primary.opacity(0.8))
                        .symbolEffect(.pulse, options: .repeating)
                }

                VStack(spacing: 12) {
                    Text(state.message)
                        .font(.headline)
                        .foregroundStyle(.primary.opacity(0.9))
                        .multilineTextAlignment(.center)

                    ProgressView()
                        .tint(.primary.opacity(0.6))
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.ultraThinMaterial)
            .ignoresSafeArea(.all)
            .transition(.opacity)
        }
    }
}

// MARK: - View Modifier

private struct SWPageLoadingModifier: ViewModifier {
    let page: SWLoadingPage

    private var state: SWPageLoadingState {
        SWLoadingManager.shared.state(for: page)
    }

    func body(content: Content) -> some View {
        content
            .overlay {
                SWPageLoadingView(page: page)
            }
            .animation(.easeInOut(duration: 0.25), value: state.isShowing)
    }
}

// MARK: - View Extension

extension View {
    /// 给视图挂载 page-level loading 支持
    func swPageLoading(_ page: SWLoadingPage) -> some View {
        modifier(SWPageLoadingModifier(page: page))
    }
}
