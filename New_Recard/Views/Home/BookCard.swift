//
//  BookCard.swift
//  New_Recard
//
//  Vertical card for the 2-column book grid on the home screen.
//  Shows cover image on top (portrait orientation) with title and author below.
//

import SwiftUI

/// Displays a book's cover image, title, and author in a vertical card layout.
/// Used inside a 2-column LazyVGrid on the home screen.
struct BookCard: View {
    /// The book to display
    let book: Book

    var body: some View {
        VStack(spacing: 0) {
            // ── Cover Image (portrait, top area) ──
            coverImage

            // ── Title & Author (centered, bottom area) ──
            VStack(spacing: 4) {
                Text(book.title)
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(AppTheme.textPrimary)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)

                Text(book.author)
                    .font(.caption)
                    .foregroundStyle(AppTheme.textSecondary)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 10)
            .padding(.vertical, 12)
        }
        .background(AppTheme.cardFill)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                .stroke(AppTheme.divider, lineWidth: 1)
        )
    }

    /// Renders the cover image in portrait orientation, or a tinted placeholder
    @ViewBuilder
    private var coverImage: some View {
        GeometryReader { geo in
            ZStack {
                // Gold-tinted placeholder background
                Rectangle()
                    .fill(AppTheme.cardFill)

                if let imageData = book.coverImageData,
                   let uiImage = UIImage(data: imageData) {
                    // Saved cover image — fill the portrait frame
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: geo.size.width, height: geo.size.height)
                        .clipped()
                } else {
                    // Placeholder icon
                    Image(systemName: "text.book.closed.fill")
                        .font(.system(size: 32))
                        .foregroundStyle(AppTheme.primary.opacity(0.4))
                }
            }
        }
        // Portrait aspect ratio (3:4) — taller than wide, matching the mid-fid
        .aspectRatio(3.0 / 4.0, contentMode: .fit)
        .clipShape(
            UnevenRoundedRectangle(
                topLeadingRadius: AppTheme.cornerRadius,
                bottomLeadingRadius: 0,
                bottomTrailingRadius: 0,
                topTrailingRadius: AppTheme.cornerRadius
            )
        )
    }
}

#Preview {
    LazyVGrid(columns: [GridItem(.flexible(), spacing: 16), GridItem(.flexible())]) {
        BookCard(book: Book(title: "Atomic Habits", author: "James Clear"))
        BookCard(book: Book(title: "Factfulness", author: "Hans Rosling"))
    }
    .padding(AppTheme.pagePadding)
    .background(Color(UIColor.systemBackground).overlay(AppTheme.backgroundPrimary))
    .preferredColorScheme(.light)
}
