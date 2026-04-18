//
//  HomeView.swift
//  New_Recard
//
//  Main landing page showing recent notes and book collection.
//

import SwiftUI
import SwiftData

/// The main entry point view of the app (HomePage).
/// Displays empty state or a list of books and the most recent note.
struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    
    // Fetch all books sorted by date added
    @Query(sort: \Book.dateAdded, order: .reverse) private var books: [Book]
    
    // Fetch all notes sorted by date created to find the single most recent note
    @Query(sort: \Note.dateCreated, order: .reverse) private var notes: [Note]
    
    // State to present the AddBookView sheet
    @State private var showingAddBook = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.backgroundPrimary.ignoresSafeArea()
                
                if books.isEmpty {
                    // Empty state when no books exist (Screen 1)
                    EmptyStateView {
                        showingAddBook = true
                    }
                } else {
                    // Populated state with content (Screen 7)
                    ScrollView {
                        VStack(alignment: .leading, spacing: 32) {
                            
                            // App Header Title
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Recard")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundStyle(AppTheme.textPrimary)
                                Text("Lorem ipsum dolor sit amet")
                                    .font(.subheadline)
                                    .foregroundStyle(AppTheme.textSecondary)
                            }
                            .padding(.horizontal)
                            .padding(.top, 16)
                            
                            // 1. Recent Note Section (Only shows if notes exist)
                            if let recentNote = notes.first {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Recent Note")
                                        .font(.headline)
                                        .foregroundStyle(AppTheme.textPrimary)
                                        .padding(.horizontal)
                                    
                                    NavigationLink(value: recentNote) {
                                        RecentNoteCard(note: recentNote)
                                            .padding(.horizontal)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            
                            // 2. Books Gallery Section
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Books")
                                    .font(.headline)
                                    .foregroundStyle(AppTheme.textPrimary)
                                    .padding(.horizontal)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 16) {
                                        ForEach(books) { book in
                                            NavigationLink(value: book) {
                                                BookCard(book: book)
                                            }
                                            .buttonStyle(.plain)
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                            }
                            
                            Spacer(minLength: 40)
                        }
                    }
                }
            }
            .navigationTitle("Recard")
            .navigationBarTitleDisplayMode(.inline)
            // Hide default nav bar in populated state as we have a custom header
            .toolbar(books.isEmpty ? .visible : .hidden, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddBook = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(AppTheme.textPrimary, AppTheme.backgroundSecondary)
                            .font(.title2)
                    }
                }
            }
            // Use NavigationStack value-based navigation for deep linking
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
}

#Preview {
    HomeView()
        .modelContainer(for: [Book.self, Note.self], inMemory: true)
        .preferredColorScheme(.dark)
}
