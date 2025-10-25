//
//  ContentView.swift
//  Noma
//
//  Created by Joshua Kraft on 24.10.25.
//

import SwiftUI

struct ContentView: View {
    @State private var search: String = ""

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

            Tab("AI", systemImage: "sparkles", role: .search) {
                NavigationStack {
                    AIActionPlaceholder()
                        .navigationTitle("Coach")
                }
            }
        }
        // Bind the AI-Action Button to searchable; this activates when the search-role tab is invoked.
        .searchable(text: $search, placement: .automatic, prompt: Text("Ask your coach…"))
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

private struct AIActionPlaceholder: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "sparkles")
                .font(.system(size: 44, weight: .regular))
                .foregroundStyle(.tint)
            Text("AI Coach")
                .font(.title2.weight(.semibold))
            Text("Use the search button to ask, edit, or replan.\nVoice-first interactions can be added here.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
        .background(.background)
    }
}

#Preview {
    ContentView()
}
