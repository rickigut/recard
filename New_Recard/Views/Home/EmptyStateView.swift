//
//  EmptyStateView.swift
//  New_Recard
//
//  Empty state shown when the user's library has no books yet.
//  Symmetrical, centered layout with outline icon and minimal instruction text.
//

import SwiftUI

/// Full-height empty state with an icon, instructional text, and CTA button.
/// Rendered inside HomeView when no books exist.
struct EmptyStateView: View {
    /// Triggered when the user taps the CTA button
    var onAddBook: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            // Icon container — squircle with subtle fill
            RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                .fill(Color.gray.opacity(0.1))
                .frame(width: 160, height: 180)
                .overlay {
                    Image(systemName: "books.vertical.fill")
                        .font(.system(size: 52))
                        .foregroundStyle(AppTheme.iconSecondary.opacity(0.5))
                }

            // Instruction text — minimalist
            Text("Your reading highlights live here.\nAdd a book to get started.")
                .font(.subheadline)
                .foregroundStyle(AppTheme.textSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)

            // Primary CTA button — #FAD100
            Button(action: onAddBook) {
                Text("Add your first book")
                    .font(.headline)
                    .foregroundStyle(AppTheme.textPrimary)
                    .padding(.horizontal, 32)
                    .frame(height: 50)
                    .background(AppTheme.primary)
                    .clipShape(Capsule())
            }
        }
    }
}

#Preview {
    EmptyStateView(onAddBook: {})
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppTheme.backgroundBase)
        .preferredColorScheme(.light)
}
