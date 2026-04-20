//
//  NoteDetailView.swift
//  New_Recard
//
//  Full-screen read-only view of a single Cornell-method note.
//

import SwiftUI
import SwiftData

/// Displays the full Cues, Notes, and Summary content of a note.
/// Provides Edit / Delete via a toolbar menu.
struct NoteDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    /// The note being viewed
    @Bindable var note: Note

    @State private var showingEditNote = false
    @State private var showingDeleteAlert = false

    var body: some View {
        ZStack {
            Color(UIColor.systemBackground)
                .overlay(AppTheme.backgroundPrimary)
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 32) {

                    // ── Cues Section ──
                    noteSection(
                        title: "Cues",
                        hint: "Key questions or trigger words",
                        content: note.cues
                    )

                    // ── Notes Section ──
                    noteSection(
                        title: "Notes",
                        hint: "Reading highlights and observations",
                        content: note.content
                    )

                    // ── Summary Section ──
                    noteSection(
                        title: "Summary",
                        hint: "Core takeaway from this reading",
                        content: note.summary
                    )

                    Spacer(minLength: 40)
                }
                .padding(AppTheme.pagePadding)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    // Edit — black icon and text
                    Button { showingEditNote = true } label: {
                        Label("Edit", systemImage: "pencil")
                    }
                    .tint(.primary)

                    // Delete — red icon and text
                    Button(role: .destructive) { showingDeleteAlert = true } label: {
                        Label("Delete", systemImage: "trash")
                    }
                    .tint(.red)
                } label: {
                    // Ellipsis icon only — no circular background
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
        .tint(.primary)
    }

    // MARK: - Section Builder

    /// Reusable section displaying a label, hint, and the note content inside a tinted card
    private func noteSection(title: String, hint: String, content: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            // Section header
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.title3.bold())
                    .foregroundStyle(AppTheme.textPrimary)
                Text(hint)
                    .font(.footnote)
                    .foregroundStyle(AppTheme.textSecondary)
            }

            // Content card with gold tint
            Text(content.isEmpty ? "—" : content)
                .font(.body)
                .foregroundStyle(content.isEmpty ? AppTheme.textPlaceholder : AppTheme.textPrimary)
                .lineSpacing(5)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
                .background(AppTheme.cardFill)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusSmall))
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.cornerRadiusSmall)
                        .stroke(AppTheme.divider, lineWidth: 1)
                )
        }
    }

    /// Deletes the note and pops navigation
    private func deleteNote() {
        modelContext.delete(note)
        dismiss()
    }
}
