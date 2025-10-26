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
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 12) {
                Text(workout.title)
                    .font(.headline)
                    .foregroundStyle(.primary)
                
                Spacer()
                
                HStack(spacing: 8) {
                    Text("\(workout.duration) min")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text(categoryMainType)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(categoryColor)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(
                            categoryColor.opacity(0.12),
                            in: RoundedRectangle(cornerRadius: 6)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .strokeBorder(categoryColor.opacity(0.2), lineWidth: 0.5)
                        )
                }
                
                if workout.completed {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.body)
                        .foregroundStyle(.green)
                }
            }
            
            Text(secondaryInfo)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .background(.ultraThickMaterial, in: RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 2)
        .contentShape(Rectangle())
    }
    
    private var categoryMainType: String {
        switch workout.category {
        case .gym: return "Gym"
        case .run: return "Run"
        case .bike: return "Bike"
        case .swim: return "Swim"
        case .hiit: return "HIIT"
        }
    }
    
    private var categoryColor: Color {
        switch workout.category {
        case .gym: return Color(red: 1.0, green: 0.58, blue: 0.0) // Vibrant orange
        case .run: return Color(red: 0.0, green: 0.48, blue: 1.0) // Vibrant blue
        case .bike: return Color(red: 0.69, green: 0.32, blue: 0.87) // Vibrant purple
        case .swim: return Color(red: 0.0, green: 0.78, blue: 0.85) // Vibrant cyan
        case .hiit: return Color(red: 1.0, green: 0.23, blue: 0.19) // Vibrant red
        }
    }
    
    private var secondaryInfo: String {
        let subcategory: String
        switch workout.category {
        case .gym(let sub):
            subcategory = formatSubcategory(sub.rawValue)
        case .run(let sub):
            subcategory = formatSubcategory(sub.rawValue)
        case .bike(let sub):
            subcategory = formatSubcategory(sub.rawValue)
        case .swim(let sub):
            subcategory = formatSubcategory(sub.rawValue)
        case .hiit(let sub):
            subcategory = formatSubcategory(sub.rawValue)
        }
        
        let totalRounds = workout.exerciseRounds.reduce(0) { sum, round in
            sum + round.rounds
        }
        
        let uniqueExercises = workout.exerciseRounds.reduce(0) { sum, round in
            sum + round.exercises.count
        }
        
        return "\(subcategory) • \(totalRounds) round\(totalRounds == 1 ? "" : "s") with \(uniqueExercises) different exercise\(uniqueExercises == 1 ? "" : "s")"
    }
    
    private func formatSubcategory(_ rawValue: String) -> String {
        rawValue.replacingOccurrences(of: "_", with: " ").capitalized
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

