//
//  BookCard.swift
//  New_Recard
//
//  Card component for the horizontal book gallery on the home screen.
//

import SwiftUI

/// Compact card displaying a book's cover and title in the home gallery.
/// Tapping navigates to BookDetailView via NavigationLink in the parent.
struct BookCard: View {
    /// The book to display
    let book: Book

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Cover image or placeholder thumbnail
            coverImage

            // Book title below the cover
            Text(book.title)
                .font(.caption)
                .foregroundStyle(AppTheme.textPrimary)
                .lineLimit(1)
        }
        .frame(width: 120)
    }

    /// Renders the book cover image or a placeholder icon
    @ViewBuilder
    private var coverImage: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(AppTheme.backgroundSecondary)
            .frame(width: 120, height: 90)
            .overlay {
                if let imageData = book.coverImageData,
                   let uiImage = UIImage(data: imageData) {
                    // Display saved cover image
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                } else {
                    // Placeholder icon when no cover is set
                    Image(systemName: "photo")
                        .font(.title2)
                        .foregroundStyle(AppTheme.textSecondary)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

#Preview {
    BookCard(book: Book(title: "Atomic Habits", author: "James Clear"))
        .padding()
        .background(AppTheme.backgroundPrimary)
        .preferredColorScheme(.dark)
}
