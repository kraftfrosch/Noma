//
//  WorkoutCardView.swift
//  Noma
//
//  Created by Joshua Kraft on 25.10.25.
//

import SwiftUI

struct WorkoutCardView: View {
    let workout: Workout
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(workout.title)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    
                    Text(categoryDisplay)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                if workout.completed {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title3)
                        .foregroundStyle(.green)
                }
            }
            
            Divider()
            
            HStack(spacing: 20) {
                MetricView(icon: "clock", value: "\(workout.duration) min")
                MetricView(icon: "figure.mixed.cardio", value: exerciseCountDisplay)
            }
        }
        .padding(16)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
        .contentShape(Rectangle())
    }
    
    private var categoryDisplay: String {
        switch workout.category {
        case .gym(let subcategory):
            return "Gym • \(subcategoryName(subcategory.rawValue))"
        case .run(let subcategory):
            return "Run • \(subcategoryName(subcategory.rawValue))"
        case .bike(let subcategory):
            return "Bike • \(subcategoryName(subcategory.rawValue))"
        case .swim(let subcategory):
            return "Swim • \(subcategoryName(subcategory.rawValue))"
        case .hiit(let subcategory):
            return "HIIT • \(subcategoryName(subcategory.rawValue))"
        }
    }
    
    private func subcategoryName(_ rawValue: String) -> String {
        rawValue.replacingOccurrences(of: "_", with: " ").capitalized
    }
    
    private var exerciseCountDisplay: String {
        let totalExercises = workout.exerciseRounds.reduce(0) { sum, round in
            sum + round.exercises.count
        }
        return "\(totalExercises) exercise\(totalExercises == 1 ? "" : "s")"
    }
}

private struct MetricView: View {
    let icon: String
    let value: String
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    let sampleWorkout = Workout(
        id: "preview-1",
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
                        explanation: "Test"
                    )
                ],
                explanation: "Test round"
            )
        ],
        explanation: "Sample workout"
    )
    
    return WorkoutCardView(workout: sampleWorkout)
        .padding()
}

