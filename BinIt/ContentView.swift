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
    @State private var showLogin: Bool = false
    @AppStorage("tutorial.seen") private var tutorialSeen = false
    @AppStorage("onboarding.seen") private var onboardingSeen = false
    @AppStorage("debug.alwaysShowOnboarding") private var alwaysShowOnboarding = false
    @AppStorage("auth.loggedIn") private var loggedIn = false
    @AppStorage("debug.alwaysShowLogin") private var alwaysShowLogin = false

    var body: some View {
        ZStack {
            NavigationStack {
                HomeView()
                    .tint(.black)
            }
            .opacity((showSplash || showOnboarding || showTutorial || showLogin) ? 0 : 1)

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
                            if !tutorialSeen {
                                showTutorial = true
                            } else if (!loggedIn || alwaysShowLogin) {
                                showLogin = true
                            }
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
                            if (!loggedIn || alwaysShowLogin) {
                                showLogin = true
                            }
                        }
                    }
                }
                .transition(.opacity)
            }

            if showLogin {
                NavigationStack {
                    LoginView {
                        loggedIn = true
                        withAnimation(.easeInOut(duration: 0.3)) {
                            showLogin = false
                        }
                    }
                }
                .transition(.opacity)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                withAnimation(.easeInOut(duration: 0.4)) {
                    if alwaysShowOnboarding {
                        onboardingSeen = false
                    }
                    if alwaysShowLogin {
                        loggedIn = false
                    }
                    showSplash = false
                    // After splash, show onboarding first if not seen; else show tutorial if not seen
                    if alwaysShowOnboarding || !onboardingSeen {
                        showOnboarding = true
                    } else if !tutorialSeen {
                        showTutorial = true
                    } else if (!loggedIn || alwaysShowLogin) {
                        showLogin = true
                    }
                }
            }
        }
        .onChange(of: loggedIn) { newValue in
            if !newValue {
                withAnimation(.easeInOut(duration: 0.3)) {
                    showLogin = true
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
