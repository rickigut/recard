//
//  AppTheme.swift
//  New_Recard
//
//  Hi-fi design system for Recard.
//  Strict monochromatic palette derived entirely from #FAD100.
//  Only value (brightness) and opacity are manipulated — no foreign hues.
//

import SwiftUI

/// Centralized design tokens for the Recard hi-fi theme.
/// Every color is derived from #FAD100 (HSB 50°, 100%, 98%)
/// by adjusting brightness or opacity only.
enum AppTheme {

    // MARK: - Brand Primary

    /// Full-strength brand gold — #FAD100
    static let primary = Color(red: 250 / 255, green: 209 / 255, blue: 0 / 255)

    /// Darker gold for pressed / hover states — ~70% brightness
    static let primaryPressed = Color(hue: 50 / 360, saturation: 1.0, brightness: 0.70)

    // MARK: - Tinted Backgrounds (gold at low opacity for clean cards & sections)

    /// Extremely subtle gold wash for the main canvas — 4% opacity
    static let backgroundPrimary = Color(red: 250 / 255, green: 209 / 255, blue: 0 / 255)
        .opacity(0.04)

    /// Light gold tint for cards & elevated surfaces — 10% opacity
    static let cardFill = Color(red: 250 / 255, green: 209 / 255, blue: 0 / 255)
        .opacity(0.10)

    /// Medium gold tint for input fields — 8% opacity
    static let inputFill = Color(red: 250 / 255, green: 209 / 255, blue: 0 / 255)
        .opacity(0.08)

    /// Soft gold stroke for borders / dividers — 15% opacity
    static let divider = Color(red: 250 / 255, green: 209 / 255, blue: 0 / 255)
        .opacity(0.15)

    // MARK: - Text (dark shades of #FAD100 for readability)

    /// Near-black with gold hue — primary text (titles, body)
    static let textPrimary = Color(hue: 50 / 360, saturation: 0.60, brightness: 0.18)

    /// Medium-dark gold — secondary text (captions, labels)
    static let textSecondary = Color(hue: 50 / 360, saturation: 0.40, brightness: 0.40)

    /// Placeholder text — lighter shade
    static let textPlaceholder = Color(hue: 50 / 360, saturation: 0.20, brightness: 0.65)

    // MARK: - Iconography

    /// Icon tint — slightly muted gold for non-primary icons
    static let iconSecondary = Color(hue: 50 / 360, saturation: 0.30, brightness: 0.55)

    // MARK: - Semantic

    /// Destructive actions — dark desaturated shade (no red)
    static let destructive = Color(hue: 50 / 360, saturation: 0.80, brightness: 0.35)

    // MARK: - Layout Constants

    /// Consistent corner radius across cards & buttons
    static let cornerRadius: CGFloat = 16

    /// Smaller corner radius for inputs & chips
    static let cornerRadiusSmall: CGFloat = 12

    /// Standard horizontal page padding
    static let pagePadding: CGFloat = 24
}
