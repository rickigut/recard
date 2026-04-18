//
//  EmptyStateView.swift
//  New_Recard
//
//  Empty state shown when the user's library has no books yet.
//  Encourages the first action with a friendly prompt.
//

import SwiftUI

/// Full-height empty state with an icon and CTA button.
/// Rendered inside HomeView when no books exist.
struct EmptyStateView: View {
    /// Triggered when the user taps "Add your first book"
    var onAddBook: () -> Void

    var body: some View {
        VStack(spacing: 28) {
            // Placeholder icon container with gold tint
            RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                .fill(AppTheme.cardFill)
                .frame(width: 140, height: 180)
                .overlay {
                    Image(systemName: "books.vertical.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(AppTheme.primary.opacity(0.6))
                }

            // Encouraging subtitle
            Text("Your reading highlights live here.\nAdd a book to get started.")
                .font(.callout)
                .foregroundStyle(AppTheme.textSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)

            // Primary CTA button
            Button(action: onAddBook) {
                Text("Add your first book")
                    .font(.headline)
                    .foregroundStyle(AppTheme.textPrimary)
                    .frame(width: 200, height: 50)
                    .background(AppTheme.primary)
                    .clipShape(RoundedRectangle(cornerRadius: 25))
            }
        }
        .padding(.horizontal, AppTheme.pagePadding)
    }
}

#Preview {
    EmptyStateView(onAddBook: {})
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(UIColor.systemBackground).overlay(AppTheme.backgroundPrimary))
        .preferredColorScheme(.light)
}
