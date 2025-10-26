//
//  WorkoutDataManager.swift
//  Noma
//
//  Created by Joshua Kraft on 25.10.25.
//

import Foundation

@Observable
class WorkoutDataManager {
    var workouts: [Workout] = []
    var isLoading: Bool = false
    var error: Error?
    
    init() {
        loadWorkouts()
    }
    
    func loadWorkouts() {
        isLoading = true
        error = nil
        
        guard let url = Bundle.main.url(forResource: "workouts", withExtension: "json") else {
            error = NSError(domain: "WorkoutDataManager", code: 404, userInfo: [NSLocalizedDescriptionKey: "workouts.json not found"])
            isLoading = false
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            workouts = try decoder.decode([Workout].self, from: data)
            isLoading = false
        } catch {
            self.error = error
            isLoading = false
        }
    }
    
    // Group workouts by date for rendering
    func groupedWorkoutsByDate() -> [(date: Date, workouts: [Workout])] {
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withFullDate, .withDashSeparatorInDate]
        
        let grouped = Dictionary(grouping: workouts) { workout -> Date in
            dateFormatter.date(from: workout.date) ?? Date()
        }
        
        return grouped
            .sorted { $0.key < $1.key }
            .map { (key: Date, value: [Workout]) in
                (date: key, workouts: value.sorted { $0.timeSlot.sortOrder < $1.timeSlot.sortOrder })
            }
    }
    
    // Get workouts for a specific date
    func workouts(for date: Date) -> [Workout] {
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withFullDate, .withDashSeparatorInDate]
        let dateString = dateFormatter.string(from: date)
        
        return workouts.filter { $0.date == dateString }
            .sorted { slot1, slot2 in
                slot1.timeSlot.sortOrder < slot2.timeSlot.sortOrder
            }
    }
}

// Helper for sorting time slots
extension TimeSlot {
    var sortOrder: Int {
        switch self {
        case .morning: return 0
        case .daytime: return 1
        case .evening: return 2
        }
    }
    
    var displayName: String {
        switch self {
        case .morning: return "Morning"
        case .daytime: return "Daytime"
        case .evening: return "Evening"
        }
    }
}

