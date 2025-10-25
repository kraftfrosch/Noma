//
//  WorkoutDetailView.swift
//  Noma
//
//  Created by Joshua Kraft on 25.10.25.
//

import SwiftUI

struct WorkoutDetailView: View {
    let workout: Workout
    @State private var chatMessage = ""
    @State private var isChatActive = false
    @FocusState private var isChatInputFocused: Bool
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header Section
                VStack(alignment: .leading, spacing: 12) {
                    Text(workout.title)
                        .font(.title.bold())
                    
                    HStack(spacing: 16) {
                        Label("\(workout.duration) min", systemImage: "clock")
                        Label(categoryDisplay, systemImage: categoryIcon)
                    }
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    
                    if workout.completed {
                        HStack(spacing: 6) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                            Text("Completed")
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(.green)
                        }
                        .padding(.top, 4)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                
                // Workout Explanation
                ExplanationCard(
                    title: "Workout Overview",
                    explanation: workout.explanation
                )
                .padding(.horizontal, 16)
                
                // Exercise Rounds
                ForEach(workout.exerciseRounds.sorted(by: { $0.order < $1.order })) { round in
                    ExerciseRoundView(round: round)
                        .padding(.horizontal, 16)
                }
            }
            .padding(.bottom, 32)
        }
        .background(Color(.systemGroupedBackground))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                AIAssistantButton(isChatActive: $isChatActive, isChatInputFocused: $isChatInputFocused)
            }
        }
        .safeAreaInset(edge: .bottom) {
            ChatInputView(
                chatMessage: $chatMessage,
                isChatActive: $isChatActive,
                isChatInputFocused: $isChatInputFocused
            )
        }
    }
    
    private var categoryDisplay: String {
        switch workout.category {
        case .gym(let subcategory):
            return "Gym • \(formatSubcategory(subcategory.rawValue))"
        case .run(let subcategory):
            return "Run • \(formatSubcategory(subcategory.rawValue))"
        case .bike(let subcategory):
            return "Bike • \(formatSubcategory(subcategory.rawValue))"
        case .swim(let subcategory):
            return "Swim • \(formatSubcategory(subcategory.rawValue))"
        case .hiit(let subcategory):
            return "HIIT • \(formatSubcategory(subcategory.rawValue))"
        }
    }
    
    private var categoryIcon: String {
        switch workout.category {
        case .gym: return "dumbbell.fill"
        case .run: return "figure.run"
        case .bike: return "bicycle"
        case .swim: return "figure.pool.swim"
        case .hiit: return "flame.fill"
        }
    }
    
    private func formatSubcategory(_ rawValue: String) -> String {
        rawValue.replacingOccurrences(of: "_", with: " ").capitalized
    }
}

struct ExerciseRoundView: View {
    let round: ExerciseRound
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Round Header
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Round \(round.order)")
                        .font(.headline)
                    
                    Spacer()
                    
                    if round.rounds > 1 {
                        Text("\(round.rounds) rounds")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                
                if round.restBetweenRounds > 0 {
                    Text("Rest: \(formatTime(round.restBetweenRounds)) between rounds")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
            
            // Exercises
            ForEach(round.exercises.sorted(by: { $0.order < $1.order })) { exercise in
                ExerciseView(exercise: exercise)
            }
        }
    }
    
    private func formatTime(_ seconds: Int) -> String {
        if seconds < 60 {
            return "\(seconds)s"
        }
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        if remainingSeconds == 0 {
            return "\(minutes) min"
        }
        return "\(minutes):\(String(format: "%02d", remainingSeconds)) min"
    }
}

struct ExerciseView: View {
    let exercise: Exercise
    @State private var showExplanation = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(exercise.name)
                        .font(.subheadline.weight(.semibold))
                    
                    HStack(spacing: 12) {
                        Text(volumeDisplay)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        Text(intensityDisplay)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        if let rest = exercise.rest, rest > 0 {
                            Text("Rest: \(rest)s")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                
                Spacer()
                
                if exercise.explanation != nil {
                    Button {
                        withAnimation {
                            showExplanation.toggle()
                        }
                    } label: {
                        Image(systemName: "questionmark.circle")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            
            if showExplanation, let explanation = exercise.explanation {
                Text(explanation)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.top, 4)
            }
        }
        .padding(12)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 8))
    }
    
    private var volumeDisplay: String {
        switch exercise.volume {
        case .reps(let repetitions):
            return "\(repetitions) reps"
        case .duration(let seconds):
            if seconds < 60 {
                return "\(seconds)s"
            }
            let minutes = seconds / 60
            let remainingSeconds = seconds % 60
            if remainingSeconds == 0 {
                return "\(minutes) min"
            }
            return "\(minutes):\(String(format: "%02d", remainingSeconds))"
        case .distance(let kilometers):
            return "\(String(format: "%.1f", kilometers)) km"
        }
    }
    
    private var intensityDisplay: String {
        switch exercise.intensity {
        case .weight(let kilogramms):
            if kilogramms == 0 {
                return "Bodyweight"
            }
            return "\(String(format: "%.1f", kilogramms)) kg"
        case .heartRate(let targetBpm):
            return "\(targetBpm) BPM"
        }
    }
}

struct ExplanationCard: View {
    let title: String
    let explanation: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(title, systemImage: "lightbulb.fill")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
            
            Text(explanation)
                .font(.subheadline)
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    NavigationStack {
        WorkoutDetailView(workout: Workout(
            id: "preview",
            date: "2025-10-27",
            timeSlot: .evening,
            title: "Volume Push",
            category: .gym(.volumePush),
            duration: 45,
            completed: false,
            exerciseRounds: [
                ExerciseRound(
                    id: "round-1",
                    order: 1,
                    rounds: 3,
                    restBetweenRounds: 90,
                    exercises: [
                        Exercise(
                            id: "ex-1",
                            name: "Bench Press",
                            order: 1,
                            volume: .reps(repetitions: 8),
                            intensity: .weight(kilogramms: 60),
                            rest: 30,
                            explanation: "Primary horizontal pushing movement for chest, shoulders, and triceps."
                        ),
                        Exercise(
                            id: "ex-2",
                            name: "Bulgarian Split Squats",
                            order: 2,
                            volume: .reps(repetitions: 12),
                            intensity: .weight(kilogramms: 20),
                            rest: 0,
                            explanation: "Unilateral leg exercise that builds stability and strength."
                        )
                    ],
                    explanation: "Push + Legs block combines upper body pressing with lower body strength."
                )
            ],
            explanation: "Starting your week with a volume push session to build upper body strength and muscle endurance. This workout focuses on progressive overload while maintaining proper form."
        ))
    }
}

