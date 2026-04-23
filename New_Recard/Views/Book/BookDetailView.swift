//
//  BookDetailView.swift
//  New_Recard
//
//  Detail view for a single book showing its info and associated notes.
//

import SwiftUI
import SwiftData

/// Shows book cover, title, genre, and a list of notes with timestamps.
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
            AppTheme.surfaceWhite
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        
                        // ── Full-width Cover Image ──
                        ZStack {
                            RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous)
                                .fill(AppTheme.backgroundBase)
                                .aspectRatio(16/9, contentMode: .fit)
                            
                            if let data = book.coverImageData, let image = UIImage(data: data) {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .aspectRatio(16/9, contentMode: .fit)
                                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous))
                            } else {
                                Image(systemName: "photo")
                                    .font(.title)
                                    .foregroundStyle(AppTheme.iconSecondary)
                            }
                        }
                        .padding(.horizontal, AppTheme.pagePadding)
                        .padding(.top, 12)
                        
                        // ── Book Title ──
                        Text(book.title)
                            .font(.title2.weight(.semibold))
                            .foregroundStyle(AppTheme.textPrimary)
                            .padding(.horizontal, AppTheme.pagePadding)
                            .padding(.top, 16)
                        
                        // ── Genre ──
                        Text(book.genre.rawValue)
                            .font(.title3)
                            .foregroundStyle(AppTheme.textSecondary)
                            .padding(.horizontal, AppTheme.pagePadding)
                            .padding(.top, 4)
                        
                        // ── Divider ──
                        Divider()
                            .padding(.horizontal, AppTheme.pagePadding)
                            .padding(.top, 16)
                            .padding(.bottom, 16)
                        
                        // ── Notes Section ──
                        if bookNotes.isEmpty {
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
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 40)
                        } else {
                            VStack(spacing: 12) {
                                ForEach(bookNotes) { note in
                                    Button {
                                        selectedNote = note
                                    } label: {
                                        VStack(alignment: .leading, spacing: 8) {
                                            // Keyword
                                            Text(note.cues.isEmpty ? "Untitled" : note.cues)
                                                .font(.callout.weight(.semibold))
                                                .foregroundStyle(AppTheme.textPrimary)
                                            
                                            // Notes content
                                            if !note.content.isEmpty {
                                                Text(note.content)
                                                    .font(.subheadline)
                                                    .foregroundStyle(AppTheme.textPrimary.opacity(0.8))
                                                    .lineLimit(3)
                                                    .multilineTextAlignment(.leading)
                                            }
                                            
                                            // Date + Page
                                            Text(smartDateString(for: note.dateCreated) + (note.pageNumber > 0 ? "  •  Page \(note.pageNumber)" : ""))
                                                .font(.caption)
                                                .foregroundStyle(AppTheme.textSecondary)
                                                .italic()
                                        }
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(16)
                                        .background(AppTheme.backgroundBase)
                                        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusSmall, style: .continuous))
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal, AppTheme.pagePadding)
                            .padding(.bottom, 20)
                        }
                    }
                }
                
                // ── Add Note CTA ──
                Button { showingAddNote = true } label: {
                    Text("Add note")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .foregroundStyle(AppTheme.textPrimary)
                }
                .tint(AppTheme.primary)
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .buttonBorderShape(.capsule)
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
        .foregroundStyle(Color.black)
        .tint(.black)

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
