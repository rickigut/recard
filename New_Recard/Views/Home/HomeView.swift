//
//  HomeView.swift
//  New_Recard
//
//  Root screen of the app. Custom hi-fi layout with branded header,
//  search bar at bottom, and vertically-scrollable book list.
//  Strictly follows Apple HIG with squircle corners and clean typography.
//

import SwiftUI
import SwiftData

/// Root view — custom header, empty/populated states, bottom search bar.
struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    
    /// All books, newest first
    @Query(sort: \Book.dateAdded, order: .reverse) private var books: [Book]
    
    /// All notes, newest first — `.first` is the Recent Note
    @Query(sort: \Note.dateCreated, order: .reverse) private var notes: [Note]
    
    /// Controls the Add Book & Note sheet
    @State private var showingAddBook = false
    
    /// Search text
    @State private var searchText: String = ""
    
    /// Programmatic navigation path
    @State private var navigationPath = NavigationPath()
    
    /// Books filtered by search
    private var filteredBooks: [Book] {
        if searchText.isEmpty { return books }
        return books.filter {
            $0.title.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            ZStack {
                // Base background — SystemSecondaryBackground (#F2F2F7)
                AppTheme.backgroundBase
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // ── Custom Header ──
                    header
                        .padding(.horizontal, AppTheme.pagePadding)
                        .padding(.top, 8)
                        .padding(.bottom, 16)
                    
                    // ── Content ──
                    if books.isEmpty {
                        Spacer()
                        EmptyStateView { showingAddBook = true }
                        Spacer()
                    } else {
                        populatedContent
                    }
                    
                    // ── Bottom Search Bar ──
                    searchBar
                        .padding(.horizontal, AppTheme.pagePadding)
                        .padding(.bottom, 8)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
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
    }
    
    // MARK: - Header
    
    /// Branded header — "Recard" large title + circular "+" button
    private var header: some View {
        HStack(alignment: .top) {
            Text("My Notes")
                .font(.largeTitle.bold())
                .foregroundStyle(AppTheme.textPrimary)
            
            Spacer()
            
            // Circular "+" button with thin border
            Button { showingAddBook = true } label: {
                Image(systemName: "plus")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(AppTheme.textPrimary)
                    .frame(width: 40, height: 40)
                    .background(AppTheme.surfaceWhite)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(AppTheme.borderThin, lineWidth: 0.5)
                    )
            }
        }
    }
    
    // MARK: - Bottom Search Bar
    
    /// Search bar pinned at the bottom of the screen
    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.body)
                .foregroundStyle(AppTheme.textSecondary)
            
            TextField("Search books...", text: $searchText)
                .font(.body)
                .foregroundStyle(AppTheme.textPrimary)
                .tint(AppTheme.primary)
            
            if !searchText.isEmpty {
                Button {
                    searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.body)
                        .foregroundStyle(AppTheme.textSecondary)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(AppTheme.surfaceWhite)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous)
                .stroke(AppTheme.borderThin, lineWidth: 0.5)
        )
    }
    
    // MARK: - Populated Content
    
    /// Scrollable content: Recent Note card + Books list
    private var populatedContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {
                
                // ── Recent Note ──
                if let recentNote = notes.first {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Recent Note")
                            .font(.title2.bold())
                            .foregroundStyle(AppTheme.textPrimary)
                            .padding(.horizontal, AppTheme.pagePadding)
                        
                        Button {
                            navigationPath.append(recentNote)
                        } label: {
                            HStack(spacing: 14) {
                                // Gray accent bar
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(width: 4)
                                
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(recentNote.cues.isEmpty ? "Untitled" : recentNote.cues)
                                        .font(.callout.weight(.semibold))
                                        .foregroundStyle(AppTheme.textPrimary)
                                    
                                    if !recentNote.content.isEmpty {
                                        Text(recentNote.content)
                                            .font(.subheadline)
                                            .foregroundStyle(AppTheme.textPrimary.opacity(0.8))
                                            .lineLimit(2)
                                    }
                                    
                                    Text(smartDateString(for: recentNote.dateCreated) + (recentNote.pageNumber > 0 ? "  •  Page \(recentNote.pageNumber)" : ""))
                                        .font(.caption)
                                        .foregroundStyle(AppTheme.textSecondary)
                                        .italic()
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(AppTheme.iconSecondary)
                            }
                            .padding(16)
                            .background(AppTheme.surfaceWhite)
                            .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous)
                                    .stroke(AppTheme.borderThin, lineWidth: 0.5)
                            )
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal, AppTheme.pagePadding)
                    }
                }
                
                // ── Books ──
                VStack(alignment: .leading, spacing: 12) {
                    Text("Books")
                        .font(.title2.bold())
                        .foregroundStyle(AppTheme.textPrimary)
                        .padding(.horizontal, AppTheme.pagePadding)
                    
                    // White card container for the book list
                    VStack(spacing: 0) {
                        ForEach(Array(filteredBooks.enumerated()), id: \.element.id) { index, book in
                            Button {
                                navigationPath.append(book)
                            } label: {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(book.title)
                                            .font(.callout.weight(.medium))
                                            .foregroundStyle(AppTheme.textPrimary)
                                        
                                        Text("\(book.notes.count) notes")
                                            .font(.footnote)
                                            .foregroundStyle(AppTheme.textSecondary)
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
                            
                            // Separator between rows (not after last)
                            if index < filteredBooks.count - 1 {
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
                    
                    // Empty search state
                    if !searchText.isEmpty && filteredBooks.isEmpty {
                        VStack(spacing: 10) {
                            Image(systemName: "book.closed")
                                .font(.title)
                                .foregroundStyle(AppTheme.iconSecondary)
                            Text("No books match your search.")
                                .font(.subheadline)
                                .foregroundStyle(AppTheme.textSecondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 40)
                    }
                }
                
                Spacer(minLength: 20)
            }
            .padding(.top, 8)
        }
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

#Preview {
    HomeView()
        .modelContainer(for: [Book.self, Note.self], inMemory: true)
        .preferredColorScheme(.light)
}
