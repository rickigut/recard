//
//  BookDetailView.swift
//  New_Recard
//
//  Displays book details and a list of associated notes.
//

import SwiftUI
import SwiftData

/// Detailed view for a single book. (Screen 3 & 5)
/// Shows book info, its notes, and allows adding new notes.
struct BookDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    // The book being viewed
    @Bindable var book: Book
    
    // Fetch notes specifically for this book, sorted by date created
    @Query private var allNotes: [Note]
    private var bookNotes: [Note] {
        allNotes.filter { $0.book == book }.sorted(by: { $0.dateCreated > $1.dateCreated })
    }
    
    @State private var showingAddNote = false
    @State private var showingEditBook = false
    @State private var showingDeleteAlert = false
    
    // Standard initializer
    init(book: Book) {
        self.book = book
    }
    
    var body: some View {
        ZStack {
            AppTheme.backgroundPrimary.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Book Header Section
                bookHeader
                    .padding()
                
                Rectangle()
                    .fill(AppTheme.backgroundSecondary)
                    .frame(height: 1)
                    .padding(.horizontal)
                
                // Notes List Section
                if bookNotes.isEmpty {
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(bookNotes) { note in
                                NavigationLink(value: note) {
                                    // Reuse RecentNoteCard visually, just with different data
                                    RecentNoteCard(note: note)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding()
                    }
                }
                
                // Add Note Button
                Button {
                    showingAddNote = true
                } label: {
                    Text("Add note")
                        .font(.headline)
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(AppTheme.primaryGold)
                        .clipShape(RoundedRectangle(cornerRadius: 25))
                }
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button {
                        showingEditBook = true
                    } label: {
                        Label("Edit", systemImage: "pencil")
                    }
                    
                    Button(role: .destructive) {
                        showingDeleteAlert = true
                    } label: {
                        Label("Delete", systemImage: "trash")
                            .foregroundStyle(AppTheme.destructive)
                    }
                } label: {
                    Image(systemName: "ellipsis.circle.fill")
                        .foregroundStyle(AppTheme.textPrimary, AppTheme.backgroundSecondary)
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
            Button("Delete", role: .destructive) {
                deleteBook()
            }
        } message: {
            Text("Are you sure you want to delete '\(book.title)'? This will also delete all attached notes.")
        }
    }
    
    /// Header showing cover thumbnail, title, and author
    private var bookHeader: some View {
        HStack(spacing: 16) {
            // Cover Thumbnail
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(AppTheme.backgroundSecondary)
                    .frame(width: 80, height: 110)
                
                if let data = book.coverImageData, let image = UIImage(data: data) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 80, height: 110)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                } else {
                    Image(systemName: "photo")
                        .foregroundStyle(AppTheme.textSecondary)
                }
            }
            
            // Text Info
            VStack(alignment: .leading, spacing: 4) {
                Text("Book Title")
                    .font(.caption)
                    .foregroundStyle(AppTheme.textSecondary)
                Text(book.title)
                    .font(.headline)
                    .foregroundStyle(AppTheme.textPrimary)
                
                Spacer().frame(height: 8)
                
                Text("Author")
                    .font(.caption)
                    .foregroundStyle(AppTheme.textSecondary)
                Text(book.author)
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.textPrimary)
            }
            
            Spacer()
        }
    }
    
    private func deleteBook() {
        modelContext.delete(book)
        dismiss()
    }
}
