//
//  HomeView.swift
//  New_Recard
//
//  Root screen of the app. Uses Apple's native .searchable modifier
//  and NavigationStack for HIG-compliant search and navigation.
//

import SwiftUI
import SwiftData

/// Root view — switches between empty and populated states
/// while keeping the header and "+" button always visible.
struct HomeView: View {
    @Environment(\.modelContext) private var modelContext

    /// All books, newest first
    @Query(sort: \Book.dateAdded, order: .reverse) private var books: [Book]

    /// All notes, newest first — only `.first` is used for the Recent Note
    @Query(sort: \Note.dateCreated, order: .reverse) private var notes: [Note]

    /// Controls the Add Book sheet presentation
    @State private var showingAddBook = false

    /// Search text bound to Apple's native .searchable
    @State private var searchText: String = ""

    /// Currently selected genre filter — nil means "All"
    @State private var selectedGenreFilter: BookGenre? = nil

    /// Filtered books based on search text and genre selection
    private var filteredBooks: [Book] {
        books.filter { book in
            // Search filter: match title (case-insensitive)
            let matchesSearch = searchText.isEmpty ||
                book.title.localizedCaseInsensitiveContains(searchText)

            // Genre filter: match selected genre or show all
            let matchesGenre = selectedGenreFilter == nil ||
                book.genre == selectedGenreFilter

            return matchesSearch && matchesGenre
        }
    }

    /// Genres that actually appear in the user's book collection
    private var availableGenres: [BookGenre] {
        let genreSet = Set(books.map { $0.genre })
        return BookGenre.allCases.filter { genreSet.contains($0) }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                // Full-screen gold-tinted canvas
                Color(UIColor.systemBackground)
                    .overlay(AppTheme.backgroundPrimary)
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    if books.isEmpty {
                        // ── Empty State ──
                        Spacer()
                        EmptyStateView { showingAddBook = true }
                        Spacer()
                        Spacer()
                    } else {
                        // ── Populated Content ──
                        populatedContent
                    }
                }
            }
            // HIG: Large title for the brand name
            .navigationTitle("Recard")
            // HIG: Native .searchable with bottom placement
            .searchable(text: $searchText, placement: .automatic, prompt: "Search books…")
            .toolbar {
                // "+" button — icon only, no circular background
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showingAddBook = true } label: {
                        Image(systemName: "plus")
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(AppTheme.textPrimary)
                    }
                }
            }
            .navigationDestination(for: Book.self) { book in
                BookDetailView(book: book)
            }
            .navigationDestination(for: Note.self) { note in
                NoteDetailView(note: note)
            }
            .sheet(isPresented: $showingAddBook) {
                AddBookView()
            }
        }
        .tint(AppTheme.primary) // Gold tint for the search cursor & cancel button
    }

    // MARK: - Genre Filter Chips

    /// Horizontal scrollable genre chips for filtering books
    private var genreFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                // "All" chip
                genreChip(label: "All", isSelected: selectedGenreFilter == nil) {
                    selectedGenreFilter = nil
                }

                // One chip per genre that exists in the user's library
                ForEach(availableGenres, id: \.self) { genre in
                    genreChip(label: genre.rawValue, isSelected: selectedGenreFilter == genre) {
                        selectedGenreFilter = genre
                    }
                }
            }
            .padding(.horizontal, AppTheme.pagePadding)
        }
    }

    /// A single genre chip button
    private func genreChip(label: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.footnote.weight(.medium))
                .foregroundStyle(isSelected ? AppTheme.textPrimary : AppTheme.textSecondary)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(isSelected ? AppTheme.primary.opacity(0.2) : AppTheme.cardFill)
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(isSelected ? AppTheme.primary.opacity(0.4) : AppTheme.divider, lineWidth: 1)
                )
        }
    }

    // MARK: - Populated Content

    /// Scrollable content: Recent Note, Genre filter + 2-column Book grid
    private var populatedContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {

                // ── Subtitle ──
                Text("Recall what matters from every book.")
                    .font(.callout)
                    .foregroundStyle(AppTheme.textSecondary)
                    .padding(.horizontal, AppTheme.pagePadding)

                // ── Recent Note ──
                if let recentNote = notes.first {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Recent Note")
                            .font(.title3.bold())
                            .foregroundStyle(AppTheme.textPrimary)
                            .padding(.horizontal, AppTheme.pagePadding)

                        NavigationLink(value: recentNote) {
                            RecentNoteCard(note: recentNote)
                                .padding(.horizontal, AppTheme.pagePadding)
                        }
                        .buttonStyle(.plain)
                    }
                }

                // ── Books Section ──
                VStack(alignment: .leading, spacing: 14) {
                    Text("Books")
                        .font(.title3.bold())
                        .foregroundStyle(AppTheme.textPrimary)
                        .padding(.horizontal, AppTheme.pagePadding)

                    // Genre filter chips
                    genreFilter

                    // 2-column grid — filtered results
                    let columns = [
                        GridItem(.flexible(), spacing: 16),
                        GridItem(.flexible(), spacing: 16)
                    ]

                    if filteredBooks.isEmpty {
                        // No results state
                        VStack(spacing: 10) {
                            Image(systemName: "book.closed")
                                .font(.title)
                                .foregroundStyle(AppTheme.primary.opacity(0.4))
                            Text("No books match your search.")
                                .font(.callout)
                                .foregroundStyle(AppTheme.textSecondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 40)
                    } else {
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(filteredBooks) { book in
                                NavigationLink(value: book) {
                                    BookCard(book: book)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, AppTheme.pagePadding)
                    }
                }

                Spacer(minLength: 60)
            }
        }
    }
}

#Preview {
    HomeView()
        .modelContainer(for: [Book.self, Note.self], inMemory: true)
        .preferredColorScheme(.light)
}
