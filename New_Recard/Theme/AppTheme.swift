//
//  AppTheme.swift
//  New_Recard
//
//  Centralized color tokens for the Recard app.
//  All colors are monochrome variations of the primary gold #FAD100.
//

import SwiftUI

/// Design tokens for the Recard app theme.
/// Monochrome palette derived from primary gold #FAD100 by adjusting HSB values.
enum AppTheme {

    // MARK: - Primary Gold Palette

    /// Main accent color — #FAD100 (HSB: 49°, 100%, 98%)
    static let primaryGold = Color(red: 250 / 255, green: 209 / 255, blue: 0 / 255)

    /// Darker variant for pressed states — reduced brightness
    static let primaryGoldDark = Color(red: 200 / 255, green: 168 / 255, blue: 0 / 255)

    /// Lighter variant for subtle highlights — reduced saturation
    static let primaryGoldLight = Color(red: 252 / 255, green: 228 / 255, blue: 77 / 255)

    /// Very dark muted variant for borders and dividers
    static let primaryGoldMuted = Color(red: 61 / 255, green: 52 / 255, blue: 0 / 255)

    // MARK: - Backgrounds

    /// Main app background — pure black
    static let backgroundPrimary = Color.black

    /// Elevated surface background for cards and sheets — #1C1C1E
    static let backgroundSecondary = Color(red: 28 / 255, green: 28 / 255, blue: 30 / 255)

    // MARK: - Text

    /// Primary text color — white
    static let textPrimary = Color.white

    /// Secondary/muted text color — system gray #8E8E93
    static let textSecondary = Color(red: 142 / 255, green: 142 / 255, blue: 147 / 255)
}
