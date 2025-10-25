//
//  WeeklyOverviewComponent.swift
//  Noma
//
//  Created by Joshua Kraft on 25.10.25.
//

import SwiftUI

struct WeeklyOverviewComponent: View {
    let workouts: [Workout]
    let startOfWeek: Date
    
    init(workouts: [Workout], startOfWeek: Date? = nil) {
        self.workouts = workouts
        self.startOfWeek = startOfWeek ?? Calendar.current.startOfWeek(for: Date())
    }
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<7, id: \.self) { dayOffset in
                let date = Calendar.current.date(byAdding: .day, value: dayOffset, to: startOfWeek) ?? startOfWeek
                DayIndicatorView(
                    date: date,
                    workouts: workoutsFor(date: date),
                    isToday: Calendar.current.isDateInToday(date),
                )
            }
        }
        .padding(16)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
    
    private func workoutsFor(date: Date) -> [Workout] {
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withFullDate, .withDashSeparatorInDate]
        let dateString = dateFormatter.string(from: date)
        
        return workouts.filter { $0.date == dateString }
    }
}

private struct DayIndicatorView: View {
    let date: Date
    let workouts: [Workout]
    let isToday: Bool
    
    var body: some View {
        VStack(spacing: 6) {
            Text(dayLetter)
                .font(.caption2.weight(.medium))
                .foregroundStyle(isToday ? .primary : .secondary)
            
            ZStack {
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.secondary.opacity(0.1))
                    .frame(width: 36, height: 60)
                
                if workouts.isEmpty {
                    Image(systemName: "figure.mind.and.body")
                        .font(.system(size: 16))
                        .foregroundStyle(.secondary.opacity(0.5))
                } else {
                    VStack(spacing: 0) {
                        workoutIndicator(for: .morning)
                        workoutIndicator(for: .daytime)
                        workoutIndicator(for: .evening)
                    }
                    .frame(width: 36, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                }
                
                if isToday {
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color.accentColor, lineWidth: 2)
                        .frame(width: 36, height: 60)
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    @ViewBuilder
    private func workoutIndicator(for timeSlot: TimeSlot) -> some View {
        let workout = workouts.first(where: { $0.timeSlot == timeSlot })
        
        if let workout = workout {
            Rectangle()
                .fill(colorForCategory(workout.category))
                .frame(maxHeight: .infinity)
        } else {
            Color.clear
                .frame(maxHeight: .infinity)
        }
    }
    
    private func colorForCategory(_ category: Category) -> Color {
        switch category {
        case .gym:
            return Color.blue.opacity(0.4)
        case .run:
            return Color.orange.opacity(0.4)
        case .bike:
            return Color.green.opacity(0.4)
        case .swim:
            return Color.cyan.opacity(0.4)
        case .hiit:
            return Color.red.opacity(0.4)
        }
    }
    
    private var dayLetter: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return String(formatter.string(from: date).prefix(1))
    }
}

// Calendar extension for getting start of week
extension Calendar {
    func startOfWeek(for date: Date) -> Date {
        var calendar = self
        calendar.firstWeekday = 2 // Monday
        
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        return calendar.date(from: components) ?? date
    }
}

#Preview {
    let sampleWorkouts = [
        Workout(
            id: "1",
            date: "2025-10-27",
            timeSlot: .evening,
            title: "Volume Push",
            category: .gym(.volumePush),
            duration: 45,
            completed: false,
            exerciseRounds: [],
            explanation: "Test"
        ),
        Workout(
            id: "2",
            date: "2025-10-28",
            timeSlot: .morning,
            title: "Base Run",
            category: .run(.baseZ2),
            duration: 50,
            completed: true,
            exerciseRounds: [],
            explanation: "Test"
        )
    ]
    
    return WeeklyOverviewComponent(workouts: sampleWorkouts)
        .padding()
}

