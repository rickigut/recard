//
//  NoteDetailView.swift
//  New_Recard
//
//  Full screen detail view for a reading note.
//

import SwiftUI
import SwiftData

/// Detailed view for a single Note. (Screen 6)
/// Displays the full text of Cues, Notes, and Summary.
struct NoteDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    // The note to display
    @Bindable var note: Note
    
    @State private var showingEditNote = false
    @State private var showingDeleteAlert = false
    
    var body: some View {
        ZStack {
            AppTheme.backgroundPrimary.ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 32) {
                    
                    // Cues Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Cues")
                            .font(.headline)
                            .foregroundStyle(AppTheme.textPrimary)
                        Text("Lorem ipsum dolor sit amet")
                            .font(.caption)
                            .foregroundStyle(AppTheme.textSecondary)
                        Text(note.cues)
                            .font(.body)
                            .foregroundStyle(AppTheme.textPrimary)
                    }
                    
                    // Notes Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Notes")
                            .font(.headline)
                            .foregroundStyle(AppTheme.textPrimary)
                        Text("Lorem ipsum dolor sit amet")
                            .font(.caption)
                            .foregroundStyle(AppTheme.textSecondary)
                        Text(note.content)
                            .font(.body)
                            .foregroundStyle(AppTheme.textPrimary)
                    }
                    
                    // Summary Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Summary")
                            .font(.headline)
                            .foregroundStyle(AppTheme.textPrimary)
                        Text("Lorem ipsum dolor sit amet")
                            .font(.caption)
                            .foregroundStyle(AppTheme.textSecondary)
                        Text(note.summary)
                            .font(.body)
                            .foregroundStyle(AppTheme.textPrimary)
                    }
                    
                    Spacer()
                }
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button {
                        showingEditNote = true
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
        .sheet(isPresented: $showingEditNote) {
            AddNoteView(noteToEdit: note)
        }
        .alert("Delete Note", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                deleteNote()
            }
        } message: {
            Text("Are you sure you want to delete this note?")
        }
    }
    
    private func deleteNote() {
        modelContext.delete(note)
        dismiss()
    }
}
