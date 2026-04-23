//
//  OnboardingView.swift
//  New_Recard
//
//  First-launch onboarding flow with 3 swipeable pages.
//  Only shown once — the first time the user opens the app after install.
//

import SwiftUI

/// Data model for a single onboarding page
private struct OnboardingPage: Identifiable {
    let id = UUID()
    /// SF Symbol name for the illustration
    let icon: String
    /// Page headline
    let title: String
    /// Descriptive body text
    let description: String
}

/// Three-page onboarding carousel with page dots and Next/Start button.
/// Persists completion state via @AppStorage so it only shows once.
struct OnboardingView: View {
    /// Callback when onboarding completes
    var onFinished: () -> Void
    
    /// Current page index
    @State private var currentPage = 0
    
    /// Onboarding content — 3 pages with realistic copy
    private let pages: [OnboardingPage] = [
        OnboardingPage(
            icon: "book.fill",
            title: "Build Your Library",
            description: "Add every book you've read or are reading. Keep your personal reading collection organized in one beautiful place."
        ),
        OnboardingPage(
            icon: "highlighter",
            title: "Capture Key Insights",
            description: "Capture key ideas, reflect on what matters, and keep your insights organized-all in one place."
        ),
        OnboardingPage(
            icon: "rectangle.on.rectangle.angled",
            title: "Recall Your Ideas",
            description: "Your reading highlights stay organized and easy to revisit-so you remember what matters."
        )
    ]
    
    var body: some View {
        ZStack {
            // Background
            AppTheme.backgroundBase
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // ── Page Content (swipeable) ──
                TabView(selection: $currentPage) {
                    ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                        onboardingPage(page)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.3), value: currentPage)
                
                // ── Bottom Controls ──
                bottomControls
                    .padding(.horizontal, AppTheme.pagePadding)
                    .padding(.bottom, 48)
            }
        }
    }
    
    // MARK: - Single Onboarding Page
    
    /// Layout for one onboarding page: icon area + title + description
    private func onboardingPage(_ page: OnboardingPage) -> some View {
        VStack(spacing: 0) {
            Spacer()
            
            // ── Illustration Area (placeholder icon) ──
            RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous)
                .fill(AppTheme.surfaceWhite)
                .frame(maxWidth: .infinity)
                .frame(height: 320)
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous)
                        .strokeBorder(AppTheme.borderThin, lineWidth: 0.5)
                )
                .overlay {
                    // SF Symbol as placeholder — user will replace with custom art later
                    Image(systemName: page.icon)
                        .font(.system(size: 64))
                        .foregroundStyle(AppTheme.iconSecondary.opacity(0.5))
                }
                .padding(.horizontal, AppTheme.pagePadding)
            
            Spacer()
                .frame(height: 40)
            
            // ── Text Content ──
            VStack(alignment: .leading, spacing: 12) {
                Text(page.title)
                    .font(.title.bold())
                    .foregroundStyle(AppTheme.textPrimary)
                
                Text(page.description)
                    .font(.body)
                    .foregroundStyle(AppTheme.textSecondary)
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, AppTheme.pagePadding)
            
            Spacer()
        }
    }
    
    // MARK: - Bottom Controls
    
    /// Page dots + Next/Start button
    private var bottomControls: some View {
        HStack {
            // ── Page Indicator Dots ──
            HStack(spacing: 8) {
                ForEach(0..<pages.count, id: \.self) { index in
                    Circle()
                        .fill(index == currentPage ? AppTheme.iconSecondary : AppTheme.iconSecondary.opacity(0.25))
                        .frame(width: 8, height: 8)
                        .animation(.easeInOut(duration: 0.2), value: currentPage)
                }
            }
            
            Spacer()
            
            // ── Next / Start Button ──
            Button {
                if currentPage < pages.count - 1 {
                    // Advance to next page
                    withAnimation { currentPage += 1 }
                } else {
                    // Final page → finish onboarding
                    onFinished()
                }
            } label: {
                Text(currentPage == pages.count - 1 ? "Start" : "Next")
                    .font(.headline)
                    .frame(width: 80)
                    .foregroundStyle(Color.black)
            }
            .tint(AppTheme.primary)
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .buttonBorderShape(.capsule)
        }
    }
}

#Preview {
    OnboardingView(onFinished: {})
        .preferredColorScheme(.light)
}
