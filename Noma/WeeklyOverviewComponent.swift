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
        VStack(spacing: 12) {
            HStack {
                Text("This Week")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
                
                Spacer()
            }
            
            HStack(spacing: 8) {
                ForEach(0..<7, id: \.self) { dayOffset in
                    let date = Calendar.current.date(byAdding: .day, value: dayOffset, to: startOfWeek) ?? startOfWeek
                    DayIndicatorView(
                        date: date,
                        workouts: workoutsFor(date: date),
                        isToday: Calendar.current.isDateInToday(date),
                        isCompact: false
                    )
                }
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
    let isCompact: Bool
    
    var body: some View {
        if isCompact {
            ZStack {
                Circle()
                    .fill(backgroundFill)
                    .frame(width: 32, height: 32)
                
                if workouts.isEmpty {
                    Image(systemName: "moon.fill")
                        .font(.system(size: 8))
                        .foregroundStyle(.secondary)
                } else {
                    VStack(spacing: 1.5) {
                        ForEach(Array(workouts.prefix(3).enumerated()), id: \.offset) { _, workout in
                            Circle()
                                .fill(workout.completed ? Color.green : Color.accentColor)
                                .frame(width: 3, height: 3)
                        }
                    }
                }
                
                if isToday {
                    Circle()
                        .stroke(Color.accentColor, lineWidth: 2)
                        .frame(width: 32, height: 32)
                }
            }
            .frame(maxWidth: .infinity)
        } else {
            VStack(spacing: 8) {
                Text(dayLetter)
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(isToday ? .primary : .secondary)
                
                ZStack {
                    Circle()
                        .fill(backgroundFill)
                        .frame(width: 36, height: 36)
                    
                    if workouts.isEmpty {
                        Image(systemName: "moon.fill")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    } else {
                        VStack(spacing: 2) {
                            ForEach(Array(workouts.prefix(3).enumerated()), id: \.offset) { _, workout in
                                Circle()
                                    .fill(workout.completed ? Color.green : Color.accentColor)
                                    .frame(width: 4, height: 4)
                            }
                        }
                    }
                    
                    if isToday {
                        Circle()
                            .stroke(Color.accentColor, lineWidth: 2)
                            .frame(width: 36, height: 36)
                    }
                }
                
                Text(dayNumber)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
        }
    }
    
    private var dayLetter: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return String(formatter.string(from: date).prefix(1))
    }
    
    private var dayNumber: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
    
    private var backgroundFill: Color {
        if workouts.isEmpty {
            return Color.secondary.opacity(0.1)
        }
        return Color.accentColor.opacity(0.15)
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

