//
//  RecentNoteCard.swift
//  New_Recard
//
//  Displays the single most recent note on the home screen.
//  The latest note always replaces the previous one — only one is shown.
//

import SwiftUI

/// A card summarizing the most recent reading note.
/// Shows the keyword and a truncated content with a navigation chevron.
struct RecentNoteCard: View {
    /// The note to display
    let note: Note
    
    var body: some View {
        HStack(spacing: 14) {
            // Gray accent bar on the left edge
            RoundedRectangle(cornerRadius: 2)
                .fill(Color.gray.opacity(0.3))
                .frame(width: 4)
            
            // Text content
            VStack(alignment: .leading, spacing: 6) {
                Text(note.cues.isEmpty ? "Untitled" : note.cues)
                    .font(.callout.weight(.semibold))
                    .foregroundStyle(AppTheme.textPrimary)
                
                if !note.content.isEmpty {
                    Text(note.content)
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.textPrimary.opacity(0.8))
                        .lineLimit(2)
                }
                
                Text(smartDateString(for: note.dateCreated) + (note.pageNumber > 0 ? "  •  Page \(note.pageNumber)" : ""))
                    .font(.caption)
                    .foregroundStyle(AppTheme.textSecondary)
                    .italic()
            }
            
            Spacer()
            
            // Navigation chevron
            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(AppTheme.iconSecondary)
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 18)
        .background(AppTheme.surfaceWhite)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous)
                .stroke(AppTheme.borderThin, lineWidth: 0.5)
        )
    }
    
    // MARK: - Smart Date Formatting
    
    private func smartDateString(for date: Date) -> String {
        let calendar = Calendar.current
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH.mm"
        let timeString = timeFormatter.string(from: date)
        
        if calendar.isDateInToday(date) {
            return "Today, \(timeString)"
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday, \(timeString)"
        } else {
            let dayFormatter = DateFormatter()
            dayFormatter.dateFormat = "EEE, d MMM"
            return "\(dayFormatter.string(from: date)) at \(timeString)"
        }
    }
}

#Preview {
    RecentNoteCard(
        note: Note(cues: "Why habits compound", content: "Small daily improvements lead to remarkable results over time", summary: "")
    )
    .padding(AppTheme.pagePadding)
    .background(AppTheme.backgroundBase)
    .preferredColorScheme(.light)
}
