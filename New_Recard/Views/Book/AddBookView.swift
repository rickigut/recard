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
    @State private var selectedGenre: BookGenre = .selfHelp
    @State private var selectedPhotoItem: PhotosPickerItem? = nil
    @State private var coverImageData: Data? = nil
    
    // Image source selection
    @State private var showingImageSourceDialog = false
    @State private var showingPhotoPicker = false
    @State private var showingCamera = false
    
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
            _selectedGenre = State(initialValue: book.genre)
            _coverImageData = State(initialValue: book.coverImageData)
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                
                VStack(alignment: .leading, spacing: 20) {
                    
                    // ── Full-width Cover Image ──
                    coverPicker
                    
                    // ── Book Title + Genre (grouped container) ──
                    VStack(alignment: .leading, spacing: 0) {
                        // Book Title
                        TextField("Book Title...", text: $title)
                            .font(.body)
                            .padding(.vertical, 14)
                            .padding(.horizontal, 16)
                        
                        Divider()
                            .padding(.leading, 16)
                        
                        // Genre Picker
                        HStack {
                            Picker("Genre", selection: $selectedGenre) {
                                ForEach(BookGenre.nonFictionGenres, id: \.self) { genre in
                                    Text(genre.rawValue).tag(genre)
                                }
                            }
                            .pickerStyle(.menu)
                            .tint(AppTheme.textSecondary)
                            
                            Spacer()
                        }
                        .padding(.vertical, 6)
                        .padding(.horizontal, 4)
                    }
                    .background(AppTheme.backgroundBase)
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusSmall, style: .continuous))
                    
                    // Divider
                    Divider()
                    
                    // ── First Note Fields (Only when creating a new book) ──
                    if !isEditing {
                        noteFieldsSection
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
                            .foregroundStyle(.gray)
                    }
                    .tint(.gray)
                }
                // Save (✓)
                ToolbarItem(placement: .topBarTrailing) {
                    Button { saveData() } label: {
                        Image(systemName: "checkmark")
                            .font(.body.weight(.semibold))
                            .foregroundStyle(isFormValid ? Color.primary : Color(UIColor.placeholderText))
                    }
                    .tint(AppTheme.primary)
                    .buttonStyle(.glassProminent)
                    .disabled(!isFormValid)
                }
            }
        }
    }
    
    // MARK: - Note Fields Section (Keyword, Notes, Page)
    
    /// Grouped note input fields using native components with inline placeholders.
    private var noteFieldsSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Keyword
            TextField("Keyword...", text: $keyword)
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
                    Text("Notes...")
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
            TextField("Page...", text: $pageNumberText)
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
    }
    
    // MARK: - Cover Image Picker (Full Width)
    
    private var coverPicker: some View {
        Button {
            showingImageSourceDialog = true
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous)
                    .fill(AppTheme.backgroundBase)
                    .aspectRatio(16/9, contentMode: .fit)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous)
                            .strokeBorder(AppTheme.borderThin, lineWidth: 0.5)
                    )
                
                if let coverImageData, let uiImage = UIImage(data: coverImageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .aspectRatio(16/9, contentMode: .fit)
                        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous))
                } else {
                    Image(systemName: "photo.badge.plus")
                        .font(.title2)
                        .foregroundStyle(.gray)
                }
            }
        }
        .buttonStyle(.plain)
        .confirmationDialog("Add Cover Photo", isPresented: $showingImageSourceDialog, titleVisibility: .visible) {
            Button("Take Photo") {
                showingCamera = true
            }
            Button("Choose from Gallery") {
                showingPhotoPicker = true
            }
        }
        .tint(.black)
        .photosPicker(isPresented: $showingPhotoPicker, selection: $selectedPhotoItem, matching: .images)
        .onChange(of: selectedPhotoItem) { _, newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                    coverImageData = data
                }
            }
        }
        .fullScreenCover(isPresented: $showingCamera) {
            CameraPickerView { image in
                coverImageData = image.jpegData(compressionQuality: 0.85)
            }
            .ignoresSafeArea()
        }
    }
    
    // MARK: - Save
    
    private func saveData() {
        if let book = bookToEdit {
            book.title = title
            book.genre = selectedGenre
            book.coverImageData = coverImageData
        } else {
            let newBook = Book(title: title, author: "", genre: selectedGenre, coverImageData: coverImageData)
            let page = Int(pageNumberText) ?? 0
            let initialNote = Note(cues: keyword, content: noteContent, summary: "", pageNumber: page, book: newBook)
            newBook.notes.append(initialNote)
            modelContext.insert(newBook)
        }
        dismiss()
    }
}

// MARK: - Camera Picker (UIKit Bridge)

/// A SwiftUI wrapper around UIImagePickerController configured for camera capture.
struct CameraPickerView: UIViewControllerRepresentable {
    @Environment(\.dismiss) private var dismiss
    
    /// Called with the captured image when the user takes a photo
    var onImageCaptured: (UIImage) -> Void
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.allowsEditing = true
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraPickerView
        
        init(parent: CameraPickerView) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            // Prefer the edited (cropped) image, fall back to original
            if let image = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage {
                parent.onImageCaptured(image)
            }
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
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

