//
//  AddBookView.swift
//  New_Recard
//
//  Sheet for creating a book entry along with its first note.
//  When editing, only allows updating the book's cover and title.
//

import SwiftUI
import SwiftData
import PhotosUI

/// Form to create a new book + its first note, or edit an existing book's details.
struct AddBookView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    /// If provided, the view operates in edit mode
    var bookToEdit: Book?

    // Book state
    @State private var title: String = ""
    @State private var selectedPhotoItem: PhotosPickerItem? = nil
    @State private var coverImageData: Data? = nil

    // Note state (only used when creating a new book)
    @State private var keyword: String = ""
    @State private var pageNumberText: String = ""
    @State private var noteContent: String = ""

    /// Whether we're editing an existing book
    private var isEditing: Bool { bookToEdit != nil }

    /// Validation
    private var isFormValid: Bool {
        let hasTitle = !title.trimmingCharacters(in: .whitespaces).isEmpty
        if isEditing {
            return hasTitle
        } else {
            let hasKeyword = !keyword.trimmingCharacters(in: .whitespaces).isEmpty
            let hasNote = !noteContent.trimmingCharacters(in: .whitespaces).isEmpty
            return hasTitle && (hasKeyword || hasNote)
        }
    }

    init(bookToEdit: Book? = nil) {
        self.bookToEdit = bookToEdit
        if let book = bookToEdit {
            _title = State(initialValue: book.title)
            _coverImageData = State(initialValue: book.coverImageData)
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {

                VStack(alignment: .leading, spacing: 28) {

                    // ── Cover + Book Title ──
                    HStack(alignment: .top, spacing: 20) {
                        coverPicker

                        VStack(alignment: .leading, spacing: 6) {
                            Text("Book Title")
                                .font(.body.weight(.semibold))
                                .foregroundStyle(.primary)
                            TextField("Input title...", text: $title)
                                .textFieldStyle(RecardTextFieldStyle())
                        }
                    }

                    // Divider
                    Divider()

                    // ── First Note Fields (Only when creating a new book) ──
                    if !isEditing {
                        VStack(alignment: .leading, spacing: 24) {
                            // Keyword field
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Keyword?")
                                    .font(.body.weight(.semibold))
                                    .foregroundStyle(.primary)
                                Text("What is the main idea or concept?")
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)

                                TextField("Input keyword...", text: $keyword)
                                    .textFieldStyle(RecardTextFieldStyle())
                            }

                            // Page field (numbers only)
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Page")
                                    .font(.body.weight(.semibold))
                                    .foregroundStyle(.primary)
                                Text("Page number reference.")
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)

                                TextField("Input page number...", text: $pageNumberText)
                                    .textFieldStyle(RecardTextFieldStyle())
                                    .keyboardType(.numberPad)
                                    .onChange(of: pageNumberText) { _, newValue in
                                        pageNumberText = newValue.filter { $0.isNumber }
                                    }
                            }

                            // Notes field
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Notes")
                                    .font(.body.weight(.semibold))
                                    .foregroundStyle(.primary)
                                Text("Write down your key takeaways and thoughts.")
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)

                                ZStack(alignment: .topLeading) {
                                    // Gray background text editor
                                    TextEditor(text: $noteContent)
                                        .frame(minHeight: 150)
                                        .padding(10)
                                        .scrollContentBackground(.hidden)
                                        .background(AppTheme.backgroundBase)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                        .tint(AppTheme.primary)

                                    // Placeholder
                                    if noteContent.isEmpty {
                                        Text("Input notes...")
                                            .foregroundStyle(Color(UIColor.placeholderText))
                                            .padding(.horizontal, 15)
                                            .padding(.vertical, 18)
                                            .allowsHitTesting(false)
                                    }
                                }
                            }
                        }
                    }

                    Spacer(minLength: 40)
                }
                .padding(AppTheme.pagePadding)
            }
            .background(AppTheme.surfaceWhite)
            .navigationTitle(isEditing ? "Edit Book" : "Add Book")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // Cancel (X)
                ToolbarItem(placement: .topBarLeading) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .font(.body.weight(.semibold))
                            .foregroundStyle(.primary)
                    }
                }
                // Save (✓)
                ToolbarItem(placement: .topBarTrailing) {
                    Button { saveData() } label: {
                        Image(systemName: "checkmark")
                            .font(.body.weight(.semibold))
                            .foregroundStyle(isFormValid ? Color.primary : Color(UIColor.placeholderText))
                    }
                    .disabled(!isFormValid)
                }
            }
        }
    }

    // MARK: - Cover Image Picker

    private var coverPicker: some View {
        PhotosPicker(
            selection: $selectedPhotoItem,
            matching: .images,
            photoLibrary: .shared()
        ) {
            ZStack {
                RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous)
                    .fill(AppTheme.backgroundBase)
                    .frame(width: 110, height: 150)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous)
                            .strokeBorder(AppTheme.borderThin, lineWidth: 0.5)
                    )

                if let coverImageData, let uiImage = UIImage(data: coverImageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 110, height: 150)
                        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous))
                } else {
                    VStack(spacing: 8) {
                        Image(systemName: "photo.badge.plus")
                            .font(.title2)
                            .foregroundStyle(.gray)
                    }
                }
            }
        }
        .onChange(of: selectedPhotoItem) { _, newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                    coverImageData = data
                }
            }
        }
    }

    // MARK: - Save

    private func saveData() {
        if let book = bookToEdit {
            book.title = title
            book.coverImageData = coverImageData
        } else {
            let newBook = Book(title: title, author: "", coverImageData: coverImageData)
            let page = Int(pageNumberText) ?? 0
            let initialNote = Note(cues: keyword, content: noteContent, summary: "", pageNumber: page, book: newBook)
            newBook.notes.append(initialNote)
            modelContext.insert(newBook)
        }
        dismiss()
    }
}

// MARK: - Custom TextField Style

struct RecardTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(AppTheme.backgroundBase)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusSmall, style: .continuous))
            .foregroundStyle(AppTheme.textPrimary)
            .tint(AppTheme.primary)
    }
}

#Preview {
    AddBookView()
        .preferredColorScheme(.light)
}
