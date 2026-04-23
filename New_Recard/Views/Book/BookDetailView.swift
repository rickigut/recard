//
//  BookDetailView.swift
//  New_Recard
//
//  Detail view for a single book showing its info and associated notes.
//

import SwiftUI
import SwiftData

/// Shows book cover, title, and a list of notes with timestamps.
/// Provides Edit / Delete via a toolbar menu and an "Add note" CTA.
struct BookDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    /// The book being displayed
    @Bindable var book: Book
    
    /// Notes sorted newest-first from the relationship
    private var bookNotes: [Note] {
        book.notes.sorted(by: { $0.dateCreated > $1.dateCreated })
    }
    
    @State private var showingAddNote = false
    @State private var showingEditBook = false
    @State private var showingDeleteAlert = false
    @State private var selectedNote: Note? = nil
    
    init(book: Book) {
        self.book = book
    }
    
    var body: some View {
        ZStack {
            AppTheme.backgroundBase
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // ── Book Info Header (white card) ──
                bookHeader
                    .padding(AppTheme.pagePadding)
                    .background(AppTheme.surfaceWhite)
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous)
                            .stroke(AppTheme.borderThin, lineWidth: 0.5)
                    )
                    .padding(.horizontal, AppTheme.pagePadding)
                    .padding(.top, 12)
                    .padding(.bottom, 16)
                
                // ── Notes Section ──
                if bookNotes.isEmpty {
                    Spacer()
                    VStack(spacing: 12) {
                        Image(systemName: "note.text")
                            .font(.system(size: 36))
                            .foregroundStyle(AppTheme.iconSecondary)
                        Text("No highlights yet.\nCapture your first insight below.")
                            .font(.subheadline)
                            .foregroundStyle(AppTheme.textSecondary)
                            .multilineTextAlignment(.center)
                            .lineSpacing(3)
                    }
                    Spacer()
                } else {
                    ScrollView(showsIndicators: false) {
                        // White card container for notes list
                        VStack(spacing: 0) {
                            ForEach(Array(bookNotes.enumerated()), id: \.element.id) { index, note in
                                Button {
                                    selectedNote = note
                                } label: {
                                    HStack {
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
                                        
                                        Image(systemName: "chevron.right")
                                            .font(.caption.weight(.semibold))
                                            .foregroundStyle(AppTheme.iconSecondary)
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 14)
                                    .contentShape(Rectangle())
                                }
                                .buttonStyle(.plain)
                                
                                if index < bookNotes.count - 1 {
                                    Divider()
                                        .padding(.leading, 16)
                                }
                            }
                        }
                        .background(AppTheme.surfaceWhite)
                        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous)
                                .stroke(AppTheme.borderThin, lineWidth: 0.5)
                        )
                        .padding(.horizontal, AppTheme.pagePadding)
                        .padding(.bottom, 20)
                    }
                }
                
                // ── Add Note CTA (gold primary button) ──
                Button { showingAddNote = true } label: {
                    Text("Add note")
                        .font(.headline)
                        .foregroundStyle(AppTheme.textPrimary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(AppTheme.primary)
                        .clipShape(Capsule())
                }
                .padding(.horizontal, AppTheme.pagePadding)
                .padding(.bottom, 16)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button { showingEditBook = true } label: {
                        Label("Edit", systemImage: "pencil")
                    }
                    
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
        .navigationDestination(item: $selectedNote) { note in
            NoteDetailView(note: note)
        }
        .sheet(isPresented: $showingAddNote) {
            AddNoteView(book: book)
        }
        .sheet(isPresented: $showingEditBook) {
            AddBookView(bookToEdit: book)
        }
        .alert("Delete Book", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) { deleteBook() }
        } message: {
            Text("Deleting \"\(book.title)\" will also remove all its notes. This action cannot be undone.")
        }
        .tint(.primary)
    }
    
    // MARK: - Book Header
    
    private var bookHeader: some View {
        HStack(spacing: 18) {
            // Cover thumbnail
            ZStack {
                RoundedRectangle(cornerRadius: AppTheme.cornerRadiusSmall, style: .continuous)
                    .fill(AppTheme.backgroundBase)
                    .frame(width: 85, height: 115)
                
                if let data = book.coverImageData, let image = UIImage(data: data) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 85, height: 115)
                        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusSmall, style: .continuous))
                } else {
                    Image(systemName: "photo")
                        .font(.title3)
                        .foregroundStyle(AppTheme.iconSecondary)
                }
            }
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadiusSmall, style: .continuous)
                    .stroke(AppTheme.borderThin, lineWidth: 0.5)
            )
            
            // Title
            VStack(alignment: .leading, spacing: 6) {
                Text("Book Title")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(AppTheme.textPrimary)
                Text(book.title)
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.textSecondary)
            }
            
            Spacer()
        }
    }
    
    private func deleteBook() {
        modelContext.delete(book)
        dismiss()
    }
    
    // MARK: - Smart Date Formatting
    
    /// Returns "Today, 22.30", "Yesterday, 14.00", or "Mon, 20 Apr at 22.30"
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
