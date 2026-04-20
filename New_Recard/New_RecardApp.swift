//
//  New_RecardApp.swift
//  New_Recard
//
//  App entry point. Manages the launch flow:
//  1. Splash screen (every launch, animated)
//  2. Onboarding (first launch only, persisted via @AppStorage)
//  3. Home screen
//

import SwiftUI
import SwiftData

@main
struct New_RecardApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Book.self,
            Note.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            RootView()
                .preferredColorScheme(.light)
        }
        .modelContainer(sharedModelContainer)
    }
}

// MARK: - Root View (Flow Controller)

/// Orchestrates the app launch flow:
/// Splash → Onboarding (if first time) → Home
struct RootView: View {
    /// Tracks which screen is currently showing
    @State private var currentScreen: LaunchScreen = .splash

    /// Persists whether onboarding has been completed (survives app restarts)
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    /// The three possible launch screens
    enum LaunchScreen {
        case splash
        case onboarding
        case home
    }

    var body: some View {
        ZStack {
            switch currentScreen {
            case .splash:
                SplashScreenView {
                    // Splash finished → check if onboarding needed
                    withAnimation(.easeInOut(duration: 0.4)) {
                        if hasCompletedOnboarding {
                            currentScreen = .home
                        } else {
                            currentScreen = .onboarding
                        }
                    }
                }
                .transition(.opacity)

            case .onboarding:
                OnboardingView {
                    // Onboarding finished → mark as completed, go to home
                    hasCompletedOnboarding = true
                    withAnimation(.easeInOut(duration: 0.4)) {
                        currentScreen = .home
                    }
                }
                .transition(.opacity)

            case .home:
                HomeView()
                    .transition(.opacity)
            }
        }
    }
}
