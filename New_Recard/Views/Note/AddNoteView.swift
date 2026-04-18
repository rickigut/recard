//
//  AddNoteView.swift
//  New_Recard
//
//  Sheet to add or edit a Cornell method note for a specific book.
//

import SwiftUI
import SwiftData

/// Form to create or edit a Note. (Screen 4)
/// Uses the Cornell Note structure: Cues, Notes, Summary.
struct AddNoteView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    // The book this note belongs to (required for new notes)
    var book: Book?
    // The note to edit (optional)
    var noteToEdit: Note?
    
    // Form State
    @State private var cues: String = ""
    @State private var content: String = ""
    @State private var summary: String = ""
    
    private var isEditing: Bool { noteToEdit != nil }
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
            // If editing, make sure book is set to the note's book if not explicitly passed
            if self.book == nil {
                self.book = note.book
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.backgroundPrimary.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        
                        // Cues Section
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Cues")
                                .font(.headline)
                                .foregroundStyle(AppTheme.textPrimary)
                            Text("Lorem ipsum dolor sit amet")
                                .font(.caption)
                                .foregroundStyle(AppTheme.textSecondary)
                            TextField("Input cues...", text: $cues)
                                .textFieldStyle(CustomTextFieldStyle())
                        }
                        
                        // Notes Section
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Notes")
                                .font(.headline)
                                .foregroundStyle(AppTheme.textPrimary)
                            Text("Lorem ipsum dolor sit amet")
                                .font(.caption)
                                .foregroundStyle(AppTheme.textSecondary)
                            
                            // TextEditor needs a background differently than TextField
                            TextEditor(text: $content)
                                .frame(height: 120)
                                .scrollContentBackground(.hidden) // Required to show custom background
                                .padding(8)
                                .background(AppTheme.backgroundSecondary)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .foregroundStyle(AppTheme.textPrimary)
                                .overlay(
                                    // Custom placeholder for TextEditor
                                    Group {
                                        if content.isEmpty {
                                            Text("Input notes...")
                                                .foregroundStyle(AppTheme.textSecondary)
                                                .padding(.horizontal, 12)
                                                .padding(.vertical, 16)
                                                .allowsHitTesting(false)
                                        }
                                    }, alignment: .topLeading
                                )
                        }
                        
                        // Summary Section
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Summary")
                                .font(.headline)
                                .foregroundStyle(AppTheme.textPrimary)
                            Text("Lorem ipsum dolor sit amet")
                                .font(.caption)
                                .foregroundStyle(AppTheme.textSecondary)
                            
                            TextEditor(text: $summary)
                                .frame(height: 80)
                                .scrollContentBackground(.hidden)
                                .padding(8)
                                .background(AppTheme.backgroundSecondary)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .foregroundStyle(AppTheme.textPrimary)
                                .overlay(
                                    Group {
                                        if summary.isEmpty {
                                            Text("Input summary...")
                                                .foregroundStyle(AppTheme.textSecondary)
                                                .padding(.horizontal, 12)
                                                .padding(.vertical, 16)
                                                .allowsHitTesting(false)
                                        }
                                    }, alignment: .topLeading
                                )
                        }
                        
                    }
                    .padding()
                }
            }
            .navigationTitle(isEditing ? "Edit Notes" : "Add Notes")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(AppTheme.textPrimary, AppTheme.backgroundSecondary)
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        saveNote()
                    } label: {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(isFormValid ? AppTheme.textPrimary : AppTheme.textSecondary,
                                             AppTheme.backgroundSecondary)
                    }
                    .disabled(!isFormValid)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
    
    private func saveNote() {
        if let note = noteToEdit {
            note.cues = cues
            note.content = content
            note.summary = summary
        } else if let targetBook = book {
            let newNote = Note(cues: cues, content: content, summary: summary)
            targetBook.notes.append(newNote) // SwiftData automatically inserts when appended to relationship
        }
        dismiss()
    }
}
