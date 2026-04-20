//
//  AddNoteView.swift
//  New_Recard
//
//  Sheet for creating or editing a Cornell-method reading note.
//

import SwiftUI
import SwiftData

/// Form to create or edit a Note using the Cornell structure:
/// Cues (key questions), Notes (main content), and Summary.
struct AddNoteView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    /// The book this note belongs to
    var book: Book?
    /// If provided, the view operates in edit mode
    var noteToEdit: Note?

    // Form state
    @State private var cues: String = ""
    @State private var content: String = ""
    @State private var summary: String = ""

    /// Whether we're editing an existing note
    private var isEditing: Bool { noteToEdit != nil }

    /// At least one field must have content
    private var isFormValid: Bool {
        !cues.trimmingCharacters(in: .whitespaces).isEmpty ||
        !content.trimmingCharacters(in: .whitespaces).isEmpty ||
        !summary.trimmingCharacters(in: .whitespaces).isEmpty
    }

    init(book: Book? = nil, noteToEdit: Note? = nil) {
        self.book = book
        self.noteToEdit = noteToEdit
        if let note = noteToEdit {
            _cues = State(initialValue: note.cues)
            _content = State(initialValue: note.content)
            _summary = State(initialValue: note.summary)
            if self.book == nil { self.book = note.book }
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(UIColor.systemBackground)
                    .overlay(AppTheme.backgroundPrimary)
                    .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 28) {

                        // ── Cues ──
                        fieldSection(
                            title: "Cues",
                            hint: "Key questions or trigger words from this reading."
                        ) {
                            TextField("Write key questions or trigger words", text: $cues)
                                .textFieldStyle(RecardTextFieldStyle())
                        }

                        // ── Notes ──
                        fieldSection(
                            title: "Notes",
                            hint: "Your reading highlights, ideas, and observations."
                        ) {
                            noteEditor(text: $content, placeholder: "Write your reading notes here…", height: 140)
                        }

                        // ── Summary ──
                        fieldSection(
                            title: "Summary",
                            hint: "A brief takeaway you want to remember."
                        ) {
                            noteEditor(text: $summary, placeholder: "Summarize the key insight…", height: 90)
                        }

                    }
                    .padding(AppTheme.pagePadding)
                }
            }
            .navigationTitle(isEditing ? "Edit Note" : "Add Note")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // Cancel — icon only
                ToolbarItem(placement: .topBarLeading) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .font(.body.weight(.semibold))
                            .foregroundStyle(AppTheme.textPrimary)
                    }
                }

                // Save — icon only
                ToolbarItem(placement: .topBarTrailing) {
                    Button { saveNote() } label: {
                        Image(systemName: "checkmark")
                            .font(.body.weight(.semibold))
                            .foregroundStyle(isFormValid ? AppTheme.primary : AppTheme.textPlaceholder)
                    }
                    .disabled(!isFormValid)
                }
            }
        }
        .tint(AppTheme.primary)
    }

    // MARK: - Reusable Section Builder

    /// Builds a labeled field section with a title, hint, and content
    private func fieldSection<Content: View>(
        title: String,
        hint: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.title3.bold())
                .foregroundStyle(AppTheme.textPrimary)
            Text(hint)
                .font(.footnote)
                .foregroundStyle(AppTheme.textSecondary)
                .lineSpacing(2)
            content()
        }
    }

    // MARK: - TextEditor with Placeholder

    /// Multi-line text editor with a custom placeholder overlay
    private func noteEditor(text: Binding<String>, placeholder: String, height: CGFloat) -> some View {
        TextEditor(text: text)
            .frame(minHeight: height)
            .scrollContentBackground(.hidden)
            .padding(12)
            .background(AppTheme.inputFill)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusSmall))
            .foregroundStyle(AppTheme.textPrimary)
            .tint(AppTheme.primary)
            .overlay(
                Group {
                    if text.wrappedValue.isEmpty {
                        Text(placeholder)
                            .foregroundStyle(AppTheme.textPlaceholder)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 20)
                            .allowsHitTesting(false)
                    }
                }, alignment: .topLeading
            )
    }

    // MARK: - Save

    /// Persists the note to SwiftData
    private func saveNote() {
        if let note = noteToEdit {
            note.cues = cues
            note.content = content
            note.summary = summary
        } else if let targetBook = book {
            let newNote = Note(cues: cues, content: content, summary: summary)
            targetBook.notes.append(newNote)
        }
        dismiss()
    }
}
