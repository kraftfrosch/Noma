//
//  ContentView.swift
//  Noma
//
//  Created by Joshua Kraft on 24.10.25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            Tab("Training", systemImage: "calendar") {
                WorkoutPlanView()
            }

            Tab("Results", systemImage: "chart.bar.fill") {
                ResultsPlaceholder()
                    .navigationTitle("Results")
            }

            Tab("Profile", systemImage: "person.crop.circle") {
                ProfilePlaceholder()
                    .navigationTitle("Profile")
            }
        }
        // Use minimize behavior on supported OS versions; no-op on older versions
        .modifier(TabBarMinimizeIfAvailable())
    }
}

// A small helper to keep the view body clean and handle availability in one place.
private struct TabBarMinimizeIfAvailable: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content.tabBarMinimizeBehavior(.onScrollDown)
        } else {
            content
        }
    }
}

private struct WorkoutPlanPlaceholder: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Image(systemName: "list.bullet.rectangle")
                    .font(.system(size: 44, weight: .regular))
                    .foregroundStyle(.secondary)
                Text("Workout Plan")
                    .font(.title2.weight(.semibold))
                Text("Scrollable list of weekly workout cards will appear here.")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding()
            .background(.background)
        }
    }
}

private struct ResultsPlaceholder: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Image(systemName: "chart.bar")
                    .font(.system(size: 44, weight: .regular))
                    .foregroundStyle(.secondary)
                Text("Results / Progress")
                    .font(.title2.weight(.semibold))
                Text("Metrics and trends will be shown here.")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding()
            .background(.background)
        }
    }
}

private struct ProfilePlaceholder: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Image(systemName: "person.crop.circle")
                    .font(.system(size: 44, weight: .regular))
                    .foregroundStyle(.secondary)
                Text("Profile")
                    .font(.title2.weight(.semibold))
                Text("Athlete preferences and profile will live here.")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding()
            .background(.background)
        }
    }
}

#Preview {
    ContentView()
}
