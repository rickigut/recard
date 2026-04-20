//
//  SplashScreenView.swift
//  New_Recard
//
//  Animated splash screen shown every time the app launches.
//  Displays the Recard logo with a scale + fade entrance animation,
//  then transitions to the next screen after a brief delay.
//

import SwiftUI

/// Full-screen splash with the Recard logo and brand name.
/// Plays a scale-up + fade-in animation on every launch.
struct SplashScreenView: View {
    /// Controls the logo scale animation
    @State private var logoScale: CGFloat = 0.6
    /// Controls the logo opacity animation
    @State private var logoOpacity: Double = 0
    /// Controls the brand text animation
    @State private var textOpacity: Double = 0
    /// Controls the gold ring rotation
    @State private var ringRotation: Double = 0
    /// Triggers navigation away from splash
    @State private var isFinished = false

    /// Callback when the splash animation completes
    var onFinished: () -> Void

    var body: some View {
        ZStack {
            // Background — clean white with subtle gold wash
            Color(UIColor.systemBackground)
                .overlay(AppTheme.backgroundPrimary)
                .ignoresSafeArea()

            VStack(spacing: 28) {
                Spacer()
                // ── Animated Logo ──
                    // Logo from assets
                    Image("recard_nbg_small")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 256, height: 256)
                
                .scaleEffect(logoScale)
                .opacity(logoOpacity)

                // ── Brand Name ──
                Text("Recard")
                    .font(.title.bold())
                    .foregroundStyle(AppTheme.textPrimary)
                    .opacity(textOpacity)

                Spacer()
                Spacer()
            }
        }
        .onAppear {
            // Phase 1: Logo scales in + fades in
            withAnimation(.easeOut(duration: 0.7)) {
                logoScale = 1.0
                logoOpacity = 1.0
            }

            // Phase 2: Ring rotates
            withAnimation(.easeInOut(duration: 1.2).delay(0.2)) {
                ringRotation = 360
            }

            // Phase 3: Brand text fades in
            withAnimation(.easeIn(duration: 0.5).delay(0.5)) {
                textOpacity = 1.0
            }

            // Phase 4: Transition out after delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                onFinished()
            }
        }
    }
}

#Preview {
    SplashScreenView(onFinished: {})
        .preferredColorScheme(.light)
}
