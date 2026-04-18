//
//  AddBookView.swift
//  New_Recard
//
//  Sheet for creating or editing a book entry.
//  Supports PhotosPicker for cover image and a genre picker.
//

import SwiftUI
import SwiftData
import PhotosUI

/// Form to create a new book or edit an existing one.
/// Presented as a sheet with Cancel / Save toolbar actions.
struct AddBookView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    /// If provided, the view operates in edit mode
    var bookToEdit: Book?

    // Form state
    @State private var title: String = ""
    @State private var author: String = ""
    @State private var selectedGenre: BookGenre = .other

    // Image picker state
    @State private var selectedPhotoItem: PhotosPickerItem? = nil
    @State private var coverImageData: Data? = nil

    /// Whether we're editing an existing book
    private var isEditing: Bool { bookToEdit != nil }

    /// Validation — both title and author are required
    private var isFormValid: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty &&
        !author.trimmingCharacters(in: .whitespaces).isEmpty
    }

    init(bookToEdit: Book? = nil) {
        self.bookToEdit = bookToEdit
        if let book = bookToEdit {
            _title = State(initialValue: book.title)
            _author = State(initialValue: book.author)
            _selectedGenre = State(initialValue: book.genre)
            _coverImageData = State(initialValue: book.coverImageData)
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(UIColor.systemBackground)
                    .overlay(AppTheme.backgroundPrimary)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 28) {

                        // ── Cover + Fields Row ──
                        HStack(alignment: .top, spacing: 20) {
                            coverPicker
                            inputFields
                        }

                        // Subtle divider
                        Rectangle()
                            .fill(AppTheme.divider)
                            .frame(height: 1)

                        Spacer()
                    }
                    .padding(AppTheme.pagePadding)
                }
            }
            .navigationTitle(isEditing ? "Edit Book" : "Add Book")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // Cancel (X) button — circular with backgroundPrimary fill
                ToolbarItem(placement: .topBarLeading) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(AppTheme.textPrimary)
                            .frame(width: 36, height: 36)
                            .background(Color.white.overlay(AppTheme.backgroundPrimary))
                            .clipShape(Circle())
                            .overlay(Circle().stroke(AppTheme.divider, lineWidth: 1))
                    }
                }

                // Save (✓) button — circular with backgroundPrimary fill
                ToolbarItem(placement: .topBarTrailing) {
                    Button { saveBook() } label: {
                        Image(systemName: "checkmark")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(isFormValid ? AppTheme.primary : AppTheme.textPlaceholder)
                            .frame(width: 36, height: 36)
                            .background(Color.white.overlay(AppTheme.backgroundPrimary))
                            .clipShape(Circle())
                            .overlay(Circle().stroke(AppTheme.divider, lineWidth: 1))
                    }
                    .disabled(!isFormValid)
                }
            }
        }
        .tint(AppTheme.primary)
    }

    // MARK: - Cover Image Picker

    /// Tappable cover image area with PhotosPicker
    private var coverPicker: some View {
        PhotosPicker(
            selection: $selectedPhotoItem,
            matching: .images,
            photoLibrary: .shared()
        ) {
            ZStack {
                RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                    .fill(AppTheme.cardFill)
                    .frame(width: 110, height: 150)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                            .strokeBorder(AppTheme.divider, lineWidth: 1)
                    )

                if let coverImageData, let uiImage = UIImage(data: coverImageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 110, height: 150)
                        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
                } else {
                    VStack(spacing: 8) {
                        Image(systemName: "photo.badge.plus")
                            .font(.title2)
                            .foregroundStyle(AppTheme.primary.opacity(0.6))
                        Text("Cover")
                            .font(.caption2)
                            .foregroundStyle(AppTheme.textPlaceholder)
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

    // MARK: - Input Fields

    /// Title, Author, and Genre fields
    private var inputFields: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Book title
            VStack(alignment: .leading, spacing: 6) {
                Text("Title")
                    .font(.footnote)
                    .foregroundStyle(AppTheme.textSecondary)
                TextField("e.g. Atomic Habits", text: $title)
                    .textFieldStyle(RecardTextFieldStyle())
            }

            // Author name
            VStack(alignment: .leading, spacing: 6) {
                Text("Author")
                    .font(.footnote)
                    .foregroundStyle(AppTheme.textSecondary)
                TextField("e.g. James Clear", text: $author)
                    .textFieldStyle(RecardTextFieldStyle())
            }

            // Genre picker
            VStack(alignment: .leading, spacing: 6) {
                Text("Genre")
                    .font(.footnote)
                    .foregroundStyle(AppTheme.textSecondary)

                Menu {
                    Picker("Genre", selection: $selectedGenre) {
                        ForEach(BookGenre.allCases, id: \.self) { genre in
                            Text(genre.rawValue).tag(genre)
                        }
                    }
                } label: {
                    HStack {
                        Text(selectedGenre.rawValue)
                            .font(.body)
                            .foregroundStyle(AppTheme.textPrimary)
                        Spacer()
                        Image(systemName: "chevron.up.chevron.down")
                            .font(.caption)
                            .foregroundStyle(AppTheme.iconSecondary)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .background(AppTheme.inputFill)
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusSmall))
                }
            }
        }
    }

    // MARK: - Save

    /// Persists the book to SwiftData and dismisses
    private func saveBook() {
        if let book = bookToEdit {
            book.title = title
            book.author = author
            book.genre = selectedGenre
            book.coverImageData = coverImageData
        } else {
            let newBook = Book(title: title, author: author, genre: selectedGenre, coverImageData: coverImageData)
            modelContext.insert(newBook)
        }
        dismiss()
    }
}

// MARK: - Custom TextField Style

/// Consistent text field style used across the app.
/// Uses a gold-tinted background with the brand cursor color.
struct RecardTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(AppTheme.inputFill)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusSmall))
            .foregroundStyle(AppTheme.textPrimary)
            .tint(AppTheme.primary)
    }
}

#Preview {
    AddBookView()
        .preferredColorScheme(.light)
}
