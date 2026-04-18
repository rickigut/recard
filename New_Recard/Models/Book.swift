//
//  Book.swift
//  New_Recard
//
//  SwiftData model representing a book in the user's reading collection.
//

import Foundation
import SwiftData

/// Represents a book that the user has read or is reading.
/// Each book can have multiple notes attached via a one-to-many relationship.
@Model
final class Book {
    /// The title of the book
    var title: String

    /// The author of the book
    var author: String

    /// Optional cover image stored as compressed JPEG data
    @Attribute(.externalStorage)
    var coverImageData: Data?

    /// Timestamp when the book was added to the collection
    var dateAdded: Date

    /// All notes associated with this book. Cascade-deletes when the book is removed.
    @Relationship(deleteRule: .cascade, inverse: \Note.book)
    var notes: [Note] = []

    init(title: String, author: String, coverImageData: Data? = nil, dateAdded: Date = .now) {
        self.title = title
        self.author = author
        self.coverImageData = coverImageData
        self.dateAdded = dateAdded
    }
}
