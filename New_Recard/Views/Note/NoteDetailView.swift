//
//  NoteDetailView.swift
//  New_Recard
//
//  Detail view for a single note showing Keyword and Notes content.
//

import SwiftUI
import SwiftData

/// Shows the full content of a single note.
struct NoteDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    /// The note being displayed
    @Bindable var note: Note
    
    @State private var showingEditNote = false
    @State private var showingDeleteAlert = false
    
    var body: some View {
        ZStack {
            // White canvas for reading/writing
            AppTheme.surfaceWhite
                .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    
                    // ── Header / Keyword ──
                    Text(note.cues.isEmpty ? "Untitled Note" : note.cues)
                        .font(.system(size: 34, weight: .bold, design: .serif))
                        .foregroundStyle(AppTheme.textPrimary)
                        .padding(.top, 16)
                    
                    // ── Metadata ──
                    HStack(spacing: 16) {
                        Label(smartDateString(for: note.dateCreated), systemImage: "calendar")
                        
                        if note.pageNumber > 0 {
                            Label("Page \(note.pageNumber)", systemImage: "book.pages")
                        }
                    }
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(AppTheme.iconSecondary)
                    
                    Divider()
                        .padding(.vertical, 8)
                    
                    // ── Content ──
                    Text(note.content.isEmpty ? "No content added yet." : note.content)
                        .font(.system(size: 18, weight: .regular, design: .serif))
                        .foregroundStyle(note.content.isEmpty ? AppTheme.textPlaceholder : AppTheme.textPrimary)
                        .lineSpacing(8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Spacer(minLength: 60)
                }
                .padding(.horizontal, AppTheme.pagePadding)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button { showingEditNote = true } label: {
                        Label("Edit", systemImage: "pencil")
                            .foregroundStyle(Color.black)
                    }
                    .tint(.black)
                    
                    Button(role: .destructive) { showingDeleteAlert = true } label: {
                        Label("Delete", systemImage: "trash")
                            .foregroundStyle(Color.red)
                    }
                    .tint(.red)
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(AppTheme.textPrimary)
                }
            }
        }
        .sheet(isPresented: $showingEditNote) {
            AddNoteView(noteToEdit: note)
        }
        .alert("Delete Note", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) { deleteNote() }
        } message: {
            Text("This note will be permanently removed. This action cannot be undone.")
        }

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
    
    // MARK: - Actions
    
    private func deleteNote() {
        modelContext.delete(note)
        dismiss()
    }
}
