//
//  SWLoading.swift
//  BobaLoyalty
//
//  ShipSwift Recipe: component-loading.
//  Full-screen page-level loading: blurred background + optional pulsing SF Symbol + customizable copy + ProgressView.
//  Each page has its own loading state, isolated via the SWLoadingPage enum.
//
//  In BobaLoyalty, two additional cases — .checkout and .cart — are already registered.
//

import SwiftUI

// MARK: - Page Loading State

/// Per-page loading state
struct SWPageLoadingState {
    var isShowing: Bool = false
    var message: String = "Loading..."
    var systemImage: String? = nil
}

// MARK: - Page Identifier

/// Page identifier enum — register every BobaLoyalty page that uses page-level loading here
enum SWLoadingPage: String {
    case home
    case settings
    case profile
    case checkout      // Checkout page mock-payment
    case cart          // Cart
    case menu          // Menu
}

// MARK: - SWLoadingManager

@MainActor
@Observable
final class SWLoadingManager {
    static let shared = SWLoadingManager()

    private var pageStates: [SWLoadingPage: SWPageLoadingState] = [:]

    private init() {}

    // MARK: - Page-level Loading

    /// Show the page-loading overlay
    func show(page: SWLoadingPage, message: String = "Loading...", systemImage: String? = nil) {
        pageStates[page] = SWPageLoadingState(isShowing: true, message: message, systemImage: systemImage)
    }

    /// Update the loading message
    func updateMessage(page: SWLoadingPage, message: String) {
        pageStates[page]?.message = message
    }

    /// Hide the page-loading overlay
    func hide(page: SWLoadingPage) {
        pageStates[page]?.isShowing = false
    }

    /// Read the loading state for a page
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
    /// Attach page-level loading support to this view
    func swPageLoading(_ page: SWLoadingPage) -> some View {
        modifier(SWPageLoadingModifier(page: page))
    }
}
