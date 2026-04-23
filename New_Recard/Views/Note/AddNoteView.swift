//
//  AddNoteView.swift
//  New_Recard
//
//  Sheet for creating or editing a note with Keyword, Notes, and Page fields.
//

import SwiftUI
import SwiftData

/// Form to create or edit a Note.
struct AddNoteView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    /// The book this note belongs to
    var book: Book?
    /// If provided, the view operates in edit mode
    var noteToEdit: Note?
    
    // Form state
    @State private var keyword: String = ""
    @State private var pageNumberText: String = ""
    @State private var noteContent: String = ""
    
    /// Whether we're editing an existing note
    private var isEditing: Bool { noteToEdit != nil }
    
    /// Validation
    private var isFormValid: Bool {
        !keyword.trimmingCharacters(in: .whitespaces).isEmpty ||
        !noteContent.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    init(book: Book? = nil, noteToEdit: Note? = nil) {
        self.book = book
        self.noteToEdit = noteToEdit
        if let note = noteToEdit {
            _keyword = State(initialValue: note.cues)
            _pageNumberText = State(initialValue: note.pageNumber > 0 ? String(note.pageNumber) : "")
            _noteContent = State(initialValue: note.content)
            if self.book == nil { self.book = note.book }
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    
                    // ── Grouped Note Fields ──
                    VStack(alignment: .leading, spacing: 0) {
                        // Keyword
                        TextField("Keyword", text: $keyword)
                            .font(.body)
                            .padding(.vertical, 14)
                            .padding(.horizontal, 16)
                        
                        Divider()
                            .padding(.leading, 16)
                        
                        // Notes — expandable TextEditor
                        ZStack(alignment: .topLeading) {
                            TextEditor(text: $noteContent)
                                .font(.body)
                                .frame(minHeight: 44)
                                .fixedSize(horizontal: false, vertical: true)
                                .padding(.horizontal, 11)
                                .padding(.vertical, 6)
                                .scrollContentBackground(.hidden)
                                .tint(AppTheme.primary)
                            
                            if noteContent.isEmpty {
                                Text("Notes")
                                    .font(.body)
                                    .foregroundStyle(AppTheme.textPlaceholder)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 14)
                                    .allowsHitTesting(false)
                            }
                        }
                        
                        Divider()
                            .padding(.leading, 16)
                        
                        // Page (Number only)
                        TextField("Page (Number only)", text: $pageNumberText)
                            .font(.body)
                            .keyboardType(.numberPad)
                            .padding(.vertical, 14)
                            .padding(.horizontal, 16)
                            .onChange(of: pageNumberText) { _, newValue in
                                pageNumberText = newValue.filter { $0.isNumber }
                            }
                    }
                    .background(AppTheme.backgroundBase)
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusSmall, style: .continuous))
                    
                    Spacer(minLength: 40)
                }
                .padding(AppTheme.pagePadding)
                .padding(.top, 16)
            }
            .background(AppTheme.surfaceWhite)
            .navigationTitle(isEditing ? "Edit Note" : "Add Notes")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .font(.body.weight(.semibold))
                            .foregroundStyle(AppTheme.textPrimary)
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button { saveNote() } label: {
                        Image(systemName: "checkmark")
                            .font(.body.weight(.semibold))
                            .foregroundStyle(isFormValid ? AppTheme.textPrimary : AppTheme.textPlaceholder)
                    }
                    .tint(AppTheme.primary)
                    .buttonStyle(.glassProminent)
                    .disabled(!isFormValid)
                }
            }
        }
    }
    
    // MARK: - Save
    
    private func saveNote() {
        let page = Int(pageNumberText) ?? 0
        if let note = noteToEdit {
            note.cues = keyword
            note.pageNumber = page
            note.content = noteContent
        } else if let book = book {
            let newNote = Note(cues: keyword, content: noteContent, summary: "", pageNumber: page, book: book)
            book.notes.append(newNote)
        }
        dismiss()
    }
}

#Preview {
    AddNoteView()
        .preferredColorScheme(.light)
}
