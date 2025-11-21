//
//  ContentView.swift
//  BinIt
//
//  Created by STUDENT on 2025-11-19.
//

import SwiftUI

struct ContentView: View {
    @State private var showSplash: Bool = true

    var body: some View {
        ZStack {
            NavigationStack {
                HomeView()
                    .tint(.black)
            }
            .opacity(showSplash ? 0 : 1)

            if showSplash {
                SplashView()
                    .transition(.opacity)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                withAnimation(.easeInOut(duration: 0.4)) {
                    showSplash = false
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
