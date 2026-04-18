//
//  AddBookView.swift
//  New_Recard
//
//  Sheet presented to add a new book or edit an existing one.
//

import SwiftUI
import SwiftData
import PhotosUI

/// Form to create or edit a Book. (Screen 2)
/// Allows selecting a cover image, title, and author.
struct AddBookView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    // Optional book to edit; if nil, we are creating a new book
    var bookToEdit: Book?
    
    // Form State
    @State private var title: String = ""
    @State private var author: String = ""
    
    // Image Picker State
    @State private var selectedPhotoItem: PhotosPickerItem? = nil
    @State private var coverImageData: Data? = nil
    
    // Determine mode based on whether a book was passed in
    private var isEditing: Bool { bookToEdit != nil }
    private var isFormValid: Bool { !title.trimmingCharacters(in: .whitespaces).isEmpty && !author.trimmingCharacters(in: .whitespaces).isEmpty }
    
    init(bookToEdit: Book? = nil) {
        self.bookToEdit = bookToEdit
        
        // Initialize state if editing (SwiftUI way to set initial state from props)
        if let book = bookToEdit {
            _title = State(initialValue: book.title)
            _author = State(initialValue: book.author)
            _coverImageData = State(initialValue: book.coverImageData)
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.backgroundPrimary.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 32) {
                        
                        // Header section with Photo and TextFields
                        HStack(spacing: 16) {
                            // Cover Image Picker
                            PhotosPicker(selection: $selectedPhotoItem, matching: .images, photoLibrary: .shared()) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(AppTheme.backgroundSecondary)
                                        .frame(width: 100, height: 140)
                                    
                                    if let coverImageData, let uiImage = UIImage(data: coverImageData) {
                                        Image(uiImage: uiImage)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 100, height: 140)
                                            .clipShape(RoundedRectangle(cornerRadius: 12))
                                    } else {
                                        Image(systemName: "photo.badge.plus")
                                            .font(.title)
                                            .foregroundStyle(AppTheme.textSecondary)
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
                            
                            // TextFields
                            VStack(alignment: .leading, spacing: 16) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Book Title")
                                        .font(.caption)
                                        .foregroundStyle(AppTheme.textSecondary)
                                    TextField("Input title...", text: $title)
                                        .textFieldStyle(CustomTextFieldStyle())
                                }
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Author")
                                        .font(.caption)
                                        .foregroundStyle(AppTheme.textSecondary)
                                    TextField("Input author...", text: $author)
                                        .textFieldStyle(CustomTextFieldStyle())
                                }
                            }
                        }
                        
                        // Custom Divider
                        Rectangle()
                            .fill(AppTheme.backgroundSecondary)
                            .frame(height: 1)
                        
                        Spacer()
                    }
                    .padding()
                }
            }
            .navigationTitle(isEditing ? "Edit Book" : "Add Book")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // Cancel (X) Button
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(AppTheme.textPrimary, AppTheme.backgroundSecondary)
                    }
                }
                
                // Save (✓) Button
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        saveBook()
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
    
    /// Saves or updates the book and dismisses the sheet
    private func saveBook() {
        if let book = bookToEdit {
            // Update existing
            book.title = title
            book.author = author
            book.coverImageData = coverImageData
        } else {
            // Create new
            let newBook = Book(title: title, author: author, coverImageData: coverImageData)
            modelContext.insert(newBook)
        }
        dismiss()
    }
}

/// Custom text field style matching the wireframes
struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(AppTheme.backgroundSecondary)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .foregroundStyle(AppTheme.textPrimary)
            .tint(AppTheme.primaryGold) // Cursor color
    }
}

#Preview {
    AddBookView()
}
