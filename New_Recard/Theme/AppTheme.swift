//
//  AppTheme.swift
//  New_Recard
//
//  Hi-fi design system for Recard.
//  Clean grayscale surfaces with #FAD100 vibrant yellow accent.
//  Follows Apple HIG color profile with SystemSecondaryBackground base.
//

import SwiftUI

/// Centralized design tokens for the Recard hi-fi theme.
enum AppTheme {

    // MARK: - Brand Primary

    /// Vibrant yellow — #FAD100 — for main action buttons and active indicators
    static let primary = Color(red: 250 / 255, green: 209 / 255, blue: 0 / 255)

    /// Darker yellow for pressed states
    static let primaryPressed = Color(hue: 50 / 360, saturation: 1.0, brightness: 0.70)

    // MARK: - Surfaces (HIG Color Profile)

    /// SystemSecondaryBackground — #F2F2F7 — main canvas background
    static let backgroundBase = Color(UIColor.secondarySystemBackground)

    /// Pure white — cards, containers, elevated surfaces
    static let surfaceWhite = Color.white

    /// Light fill for input fields — slightly off-white
    static let inputFill = Color(UIColor.tertiarySystemFill)

    // MARK: - Text (HIG Labels)

    /// Black at 90% — primary text (titles, headlines, body)
    static let textPrimary = Color.black.opacity(0.90)

    /// Secondary Label Gray — #8E8E93 — sub-descriptions, captions
    static let textSecondary = Color(UIColor.secondaryLabel)

    /// Placeholder text
    static let textPlaceholder = Color(UIColor.placeholderText)

    // MARK: - Borders & Dividers

    /// Ultra-thin border — 0.5pt separator
    static let borderThin = Color(UIColor.separator)

    // MARK: - Iconography

    /// Gray for inactive/secondary icons
    static let iconSecondary = Color(UIColor.secondaryLabel)

    // MARK: - Semantic

    /// Destructive actions — system red
    static let destructive = Color.red

    // MARK: - Layout Constants

    /// Squircle corner radius for main containers (20-24px)
    static let cornerRadius: CGFloat = 20

    /// Smaller corner radius for inputs & chips
    static let cornerRadiusSmall: CGFloat = 12

    /// Standard horizontal page padding
    static let pagePadding: CGFloat = 20
}
