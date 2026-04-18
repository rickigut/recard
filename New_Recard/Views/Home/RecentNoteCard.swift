//
//  RecentNoteCard.swift
//  New_Recard
//
//  Displays the single most recent note on the home screen.
//  The latest note always replaces the previous one — only one is shown.
//

import SwiftUI

/// A card summarizing the most recent reading note.
/// Shows the cues text and a truncated summary with a navigation chevron.
struct RecentNoteCard: View {
    /// The note to display
    let note: Note

    var body: some View {
        HStack(spacing: 14) {
            // Gold accent bar on the left edge
            RoundedRectangle(cornerRadius: 2)
                .fill(AppTheme.primary)
                .frame(width: 4)

            // Text content
            VStack(alignment: .leading, spacing: 6) {
                // Cues as the primary label
                Text(note.cues)
                    .font(.callout.weight(.semibold))
                    .foregroundStyle(AppTheme.textPrimary)
                    .lineLimit(1)

                // Summary as the secondary label — HIG Footnote
                Text(note.summary)
                    .font(.footnote)
                    .foregroundStyle(AppTheme.textSecondary)
                    .lineLimit(1)
            }

            Spacer()

            // Navigation chevron
            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(AppTheme.iconSecondary)
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 18)
        .background(AppTheme.cardFill)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                .stroke(AppTheme.divider, lineWidth: 1)
        )
    }
}

#Preview {
    RecentNoteCard(
        note: Note(cues: "Why habits compound", content: "Details", summary: "Small daily improvements lead to remarkable results over time")
    )
    .padding(AppTheme.pagePadding)
    .background(Color(UIColor.systemBackground).overlay(AppTheme.backgroundPrimary))
    .preferredColorScheme(.light)
}
