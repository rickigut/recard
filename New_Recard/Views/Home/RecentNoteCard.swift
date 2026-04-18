//
//  RecentNoteCard.swift
//  New_Recard
//
//  Card component showing the most recent note on the home screen.
//  Only one instance is displayed — the latest note always replaces any previous.
//

import SwiftUI

/// Summary card for the most recent note across all books.
/// Shows cues as the title and summary as subtitle with a navigation chevron.
struct RecentNoteCard: View {
    /// The note to display
    let note: Note

    var body: some View {
        HStack {
            // Note text content
            VStack(alignment: .leading, spacing: 4) {
                // Cues as the primary label
                Text(note.cues)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(AppTheme.textPrimary)
                    .lineLimit(1)

                // Summary as the secondary label
                Text(note.summary)
                    .font(.caption)
                    .foregroundStyle(AppTheme.textSecondary)
                    .lineLimit(1)
            }

            Spacer()

            // Navigation chevron indicator
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(AppTheme.textSecondary)
        }
        .padding()
        .background(AppTheme.backgroundSecondary)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    RecentNoteCard(
        note: Note(cues: "Note · Lorem Ipsum", content: "Content", summary: "Title Lorem")
    )
    .padding()
    .background(AppTheme.backgroundPrimary)
    .preferredColorScheme(.dark)
}
