//
//  Book.swift
//  New_Recard
//
//  SwiftData model representing a book in the user's reading collection.
//

import Foundation
import SwiftData

/// Predefined book genres for the picker.
/// Non-fiction genres only — fiction-related categories have been removed.
enum BookGenre: String, CaseIterable, Codable {
    case selfHelp = "Self-Help"
    case nonFiction = "Non-Fiction"
    case science = "Science"
    case philosophy = "Philosophy"
    case psychology = "Psychology"
    case business = "Business"
    case biography = "Biography"
    case history = "History"
    case technology = "Technology"
    case other = "Other"
    
    /// All non-fiction genres available for the picker
    static var nonFictionGenres: [BookGenre] {
        allCases
    }
}

/// Represents a book that the user has read or is reading.
/// Each book can have multiple notes attached via a one-to-many relationship.
@Model
final class Book {
    /// The title of the book
    var title: String
    
    /// The author of the book
    var author: String
    
    /// The genre of the book, stored as a raw string for SwiftData compatibility
    var genreRawValue: String
    
    /// Computed genre accessor
    var genre: BookGenre {
        get { BookGenre(rawValue: genreRawValue) ?? .other }
        set { genreRawValue = newValue.rawValue }
    }
    
    /// Optional cover image stored as compressed JPEG data
    @Attribute(.externalStorage)
    var coverImageData: Data?
    
    /// Timestamp when the book was added to the collection
    var dateAdded: Date
    
    /// All notes associated with this book. Cascade-deletes when the book is removed.
    @Relationship(deleteRule: .cascade, inverse: \Note.book)
    var notes: [Note] = []
    
    init(title: String, author: String, genre: BookGenre = .other, coverImageData: Data? = nil, dateAdded: Date = .now) {
        self.title = title
        self.author = author
        self.genreRawValue = genre.rawValue
        self.coverImageData = coverImageData
        self.dateAdded = dateAdded
    }
}
