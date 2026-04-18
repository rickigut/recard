//
//  BookDetailView.swift
//  New_Recard
//
//  Detail view for a single book showing its info and associated notes.
//

import SwiftUI
import SwiftData

/// Shows book cover, title, author, and a list of notes.
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

    init(book: Book) {
        self.book = book
    }

    var body: some View {
        ZStack {
            Color(UIColor.systemBackground)
                .overlay(AppTheme.backgroundPrimary)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // ── Book Info Header ──
                bookHeader
                    .padding(.horizontal, AppTheme.pagePadding)
                    .padding(.vertical, 20)

                // Subtle divider
                Rectangle()
                    .fill(AppTheme.divider)
                    .frame(height: 1)
                    .padding(.horizontal, AppTheme.pagePadding)

                // ── Notes Section ──
                if bookNotes.isEmpty {
                    // Friendly empty state for notes
                    Spacer()
                    VStack(spacing: 12) {
                        Image(systemName: "note.text")
                            .font(.system(size: 36))
                            .foregroundStyle(AppTheme.primary.opacity(0.4))
                        Text("No highlights yet.\nCapture your first insight below.")
                            .font(.callout)
                            .foregroundStyle(AppTheme.textSecondary)
                            .multilineTextAlignment(.center)
                            .lineSpacing(3)
                    }
                    Spacer()
                } else {
                    ScrollView(showsIndicators: false) {
                        LazyVStack(spacing: 12) {
                            ForEach(bookNotes) { note in
                                NavigationLink(value: note) {
                                    RecentNoteCard(note: note)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(AppTheme.pagePadding)
                    }
                }

                // ── Add Note CTA ──
                Button { showingAddNote = true } label: {
                    Text("Add note")
                        .font(.headline)
                        .foregroundStyle(AppTheme.textPrimary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(AppTheme.primary)
                        .clipShape(RoundedRectangle(cornerRadius: 26))
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
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(AppTheme.textPrimary)
                        .frame(width: 36, height: 36)
                        .background(Color.white.overlay(AppTheme.backgroundPrimary))
                        .clipShape(Circle())
                        .overlay(Circle().stroke(AppTheme.divider, lineWidth: 1))
                }
            }
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
    }

    // MARK: - Book Header

    /// Displays cover, title, and author in a horizontal layout
    private var bookHeader: some View {
        HStack(spacing: 18) {
            // Cover thumbnail
            ZStack {
                RoundedRectangle(cornerRadius: AppTheme.cornerRadiusSmall)
                    .fill(AppTheme.cardFill)
                    .frame(width: 85, height: 115)

                if let data = book.coverImageData, let image = UIImage(data: data) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 85, height: 115)
                        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusSmall))
                } else {
                    Image(systemName: "text.book.closed.fill")
                        .font(.title3)
                        .foregroundStyle(AppTheme.primary.opacity(0.5))
                }
            }
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadiusSmall)
                    .stroke(AppTheme.divider, lineWidth: 1)
            )

            // Title, Author & Genre — HIG hierarchy
            VStack(alignment: .leading, spacing: 6) {
                Text("Title")
                    .font(.footnote)
                    .foregroundStyle(AppTheme.textSecondary)
                Text(book.title)
                    .font(.headline)
                    .foregroundStyle(AppTheme.textPrimary)

                Spacer().frame(height: 6)

                Text("Author")
                    .font(.footnote)
                    .foregroundStyle(AppTheme.textSecondary)
                Text(book.author)
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.textPrimary)

                Spacer().frame(height: 6)

                Text("Genre")
                    .font(.footnote)
                    .foregroundStyle(AppTheme.textSecondary)
                Text(book.genre.rawValue)
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.textPrimary)
            }

            Spacer()
        }
    }

    /// Deletes the book and pops navigation
    private func deleteBook() {
        modelContext.delete(book)
        dismiss()
    }
}
