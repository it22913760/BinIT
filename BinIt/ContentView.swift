//
//  ContentView.swift
//  BinIt
//
//  Created by STUDENT on 2025-11-19.
//

import SwiftUI

struct ContentView: View {
    @State private var showSplash: Bool = true
    @State private var showTutorial: Bool = false
    @State private var showOnboarding: Bool = false
    @AppStorage("tutorial.seen") private var tutorialSeen = false
    @AppStorage("onboarding.seen") private var onboardingSeen = false

    var body: some View {
        ZStack {
            NavigationStack {
                HomeView()
                    .tint(.black)
            }
            .opacity((showSplash || showOnboarding || showTutorial) ? 0 : 1)

            if showSplash {
                SplashView()
                    .transition(.opacity)
            }

            if showOnboarding {
                NavigationStack {
                    OnboardingView {
                        onboardingSeen = true
                        withAnimation(.easeInOut(duration: 0.3)) {
                            showOnboarding = false
                            // After onboarding, show tutorial if not seen
                            if !tutorialSeen { showTutorial = true }
                        }
                    }
                }
                .transition(.opacity)
            }

            if showTutorial {
                // Full-screen tutorial shown after splash on first launch
                NavigationStack {
                    TutorialView {
                        tutorialSeen = true
                        withAnimation(.easeInOut(duration: 0.3)) {
                            showTutorial = false
                        }
                    }
                }
                .transition(.opacity)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                withAnimation(.easeInOut(duration: 0.4)) {
                    showSplash = false
                    // After splash, show onboarding first if not seen; else show tutorial if not seen
                    if !onboardingSeen {
                        showOnboarding = true
                    } else if !tutorialSeen {
                        showTutorial = true
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
