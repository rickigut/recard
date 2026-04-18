//
//  Note.swift
//  New_Recard
//
//  SwiftData model representing a reading note using the Cornell method.
//

import Foundation
import SwiftData

/// Represents a reading note following the Cornell note-taking structure.
/// Each note belongs to a single book via an inverse relationship.
@Model
final class Note {
    /// Key questions or cue words from the reading
    var cues: String

    /// Main body of reading notes and highlights
    var content: String

    /// Brief summary of the note's key takeaways
    var summary: String

    /// Timestamp when the note was created
    var dateCreated: Date

    /// The book this note belongs to (inverse of Book.notes)
    var book: Book?

    init(cues: String, content: String, summary: String, dateCreated: Date = .now, book: Book? = nil) {
        self.cues = cues
        self.content = content
        self.summary = summary
        self.dateCreated = dateCreated
        self.book = book
    }
}
