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
                    
                    // ── Book Details (read-only) ──
                    if let book = book {
                        VStack(alignment: .leading, spacing: 0) {
                            // Book Title row
                            HStack {
                                Text("Book title")
                                    .font(.body)
                                    .italic()
                                    .foregroundStyle(AppTheme.textPrimary)
                                Spacer()
                                Text(book.title)
                                    .font(.body)
                                    .foregroundStyle(AppTheme.textPrimary)
                                    .multilineTextAlignment(.trailing)
                            }
                            .padding(.vertical, 14)
                            .padding(.horizontal, 16)
                            
                            Divider()
                                .padding(.leading, 16)
                            
                            // Genre row
                            HStack {
                                Text("Genre")
                                    .font(.body)
                                    .italic()
                                    .foregroundStyle(AppTheme.textPrimary)
                                Spacer()
                                Text(book.genre.rawValue)
                                    .font(.body)
                                    .foregroundStyle(AppTheme.textSecondary)
                            }
                            .padding(.vertical, 14)
                            .padding(.horizontal, 16)
                        }
                        .background(AppTheme.backgroundBase)
                        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusSmall, style: .continuous))
                    }
                    
                    // ── Highlights Label ──
                    Text("Highlights")
                        .font(.title3.bold())
                        .foregroundStyle(AppTheme.textPrimary)
                    
                    // ── Note Fields ──
                    VStack(alignment: .leading, spacing: 0) {
                        // Note label + subtitle + TextEditor
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Note")
                                .font(.body.weight(.medium))
                                .foregroundStyle(AppTheme.textPrimary)
                                .padding(.top, 12)
                                .padding(.horizontal, 16)
                            
                            Text("What i want to remember?")
                                .font(.caption)
                                .foregroundStyle(AppTheme.textSecondary)
                                .padding(.horizontal, 16)
                            
                            ZStack(alignment: .topLeading) {
                                TextEditor(text: $keyword)
                                    .font(.body)
                                    .frame(minHeight: 36)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .padding(.horizontal, 11)
                                    .padding(.vertical, 6)
                                    .scrollContentBackground(.hidden)
                                    .tint(AppTheme.primary)
                                
                                if keyword.isEmpty {
                                    Text("Write your note here...")
                                        .font(.body)
                                        .foregroundStyle(AppTheme.textPlaceholder)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 14)
                                        .allowsHitTesting(false)
                                }
                            }
                            .padding(.bottom, 8)
                        }
                        
                        Divider()
                            .padding(.leading, 16)
                        
                        // Summary label + subtitle + TextEditor
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Summary")
                                .font(.body.weight(.medium))
                                .foregroundStyle(AppTheme.textPrimary)
                                .padding(.top, 12)
                                .padding(.horizontal, 16)
                            
                            Text("What word remind me?")
                                .font(.caption)
                                .foregroundStyle(AppTheme.textSecondary)
                                .padding(.horizontal, 16)
                            
                            ZStack(alignment: .topLeading) {
                                TextEditor(text: $noteContent)
                                    .font(.body)
                                    .frame(minHeight: 36)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .padding(.horizontal, 11)
                                    .padding(.vertical, 6)
                                    .scrollContentBackground(.hidden)
                                    .tint(AppTheme.primary)
                                
                                if noteContent.isEmpty {
                                    Text("Write your summary here...")
                                        .font(.body)
                                        .foregroundStyle(AppTheme.textPlaceholder)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 14)
                                        .allowsHitTesting(false)
                                }
                            }
                            .padding(.bottom, 8)
                        }
                        
                        Divider()
                            .padding(.leading, 16)
                        
                        // Page row — label kiri, value kanan
                        HStack {
                            Text("Page")
                                .font(.body)
                                .foregroundStyle(AppTheme.textPrimary)
                            
                            Spacer()
                            
                            TextField("Page number", text: $pageNumberText)
                                .font(.body)
                                .multilineTextAlignment(.trailing)
                                .foregroundStyle(AppTheme.textSecondary)
                                .keyboardType(.numberPad)
                                .frame(maxWidth: 100)
                                .onChange(of: pageNumberText) { _, newValue in
                                    pageNumberText = newValue.filter { $0.isNumber }
                                }
                        }
                        .padding(.vertical, 14)
                        .padding(.horizontal, 16)
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
