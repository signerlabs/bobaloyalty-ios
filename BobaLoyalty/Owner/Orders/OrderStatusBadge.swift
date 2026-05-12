//
//  OrderStatusBadge.swift
//  BobaLoyalty
//
//  Order status badge: renders a capsule-shaped colored badge based on OrderStatus.
//  - pending   → orange
//  - making    → blue
//  - ready     → green
//  - completed → gray
//  - cancelled → red
//

import SwiftUI

struct OrderStatusBadge: View {
    let status: OrderStatus

    var body: some View {
        Text(status.displayName)
            .font(.caption)
            .fontWeight(.semibold)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .foregroundStyle(textColor)
            .background(
                Capsule().fill(backgroundColor)
            )
            .overlay(
                Capsule().stroke(textColor.opacity(0.35), lineWidth: 0.5)
            )
    }

    // MARK: - Color mapping

    private var backgroundColor: Color {
        switch status {
        case .pending:   .orange.opacity(0.18)
        case .making:    .blue.opacity(0.18)
        case .ready:     .green.opacity(0.20)
        case .completed: .gray.opacity(0.18)
        case .cancelled: .red.opacity(0.18)
        }
    }

    private var textColor: Color {
        switch status {
        case .pending:   .orange
        case .making:    .blue
        case .ready:     .green
        case .completed: .secondary
        case .cancelled: .red
        }
    }
}
