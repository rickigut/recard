//
//  EmptyStateView.swift
//  New_Recard
//
//  Displayed on the home screen when no books have been added yet.
//

import SwiftUI

/// Empty state placeholder shown when the user has no books.
/// Displays a book icon and an "Add book" call-to-action button.
struct EmptyStateView: View {
    /// Callback triggered when the "Add book" button is tapped
    var onAddBook: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            // Placeholder book icon container
            RoundedRectangle(cornerRadius: 12)
                .fill(AppTheme.backgroundSecondary)
                .frame(width: 120, height: 160)
                .overlay {
                    Image(systemName: "book.closed.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(AppTheme.textSecondary)
                }

            // CTA button to add first book
            Button(action: onAddBook) {
                Text("Add book")
                    .font(.headline)
                    .foregroundStyle(.black)
                    .frame(width: 140, height: 44)
                    .background(AppTheme.primaryGold)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
    }
}

#Preview {
    EmptyStateView(onAddBook: {})
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppTheme.backgroundPrimary)
        .preferredColorScheme(.dark)
}
