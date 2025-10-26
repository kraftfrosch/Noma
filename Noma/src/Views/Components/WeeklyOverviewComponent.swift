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
    @Binding var selectedDate: Date
    var onSelectDate: (Date) -> Void
    
    init(
        workouts: [Workout],
        selectedDate: Binding<Date>,
        startOfWeek: Date? = nil,
        onSelectDate: @escaping (Date) -> Void
    ) {
        self.workouts = workouts
        self._selectedDate = selectedDate
        self.startOfWeek = startOfWeek ?? Calendar.current.startOfWeek(for: Date())
        self.onSelectDate = onSelectDate
    }
    
    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<7, id: \.self) { dayOffset in
                let date = Calendar.current.date(byAdding: .day, value: dayOffset, to: startOfWeek) ?? startOfWeek
                let isSelected = Calendar.current.isDate(date, inSameDayAs: selectedDate)

                Button {
                    onSelectDate(date)
                } label: {
                    DayIndicatorView(
                        date: date,
                        workouts: workoutsFor(date: date),
                        isToday: Calendar.current.isDateInToday(date),
                        isSelected: isSelected
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 16)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(.primary.opacity(0.05), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 2)
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
    let isSelected: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            // Day letter in circle
            ZStack {
                Circle()
                    .fill(dayLetterBackground)
                    .frame(width: 24, height: 24)
                
                Text(dayLetter)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(dayLetterColor)
            }
            
            // Workout indicator
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(indicatorBackground)
                    .frame(width: 38, height: 64)
                
                RoundedRectangle(cornerRadius: 8)
                    .strokeBorder(indicatorBorder, lineWidth: 1.5)
                    .frame(width: 38, height: 64)
                
                if workouts.isEmpty {
                    Image(systemName: "figure.mind.and.body")
                        .font(.system(size: 18, weight: .light))
                        .foregroundStyle(.secondary.opacity(0.4))
                } else {
                    VStack(spacing: 0) {
                        workoutIndicator(for: .morning)
                        workoutIndicator(for: .daytime)
                        workoutIndicator(for: .evening)
                    }
                    .frame(width: 38, height: 64)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 6)
        .padding(.horizontal, 4)
        .background(selectionBackground)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
    
    @ViewBuilder
    private func workoutIndicator(for timeSlot: TimeSlot) -> some View {
        let workout = workouts.first(where: { $0.timeSlot == timeSlot })
        
        if let workout = workout {
            RoundedRectangle(cornerRadius: 8)
                .fill(colorForCategory(workout.category))
                .frame(maxHeight: .infinity)
        } else {
            Color.clear
                .frame(maxHeight: .infinity)
        }
    }
    
    private func colorForCategory(_ category: Category) -> Color {
        baseColor(for: category).opacity(0.65)
    }
    
    private func baseColor(for category: Category) -> Color {
        switch category {
        case .gym:
            return Color(red: 1.0, green: 0.58, blue: 0.0)
        case .run:
            return Color(red: 0.0, green: 0.48, blue: 1.0)
        case .bike:
            return Color(red: 0.69, green: 0.32, blue: 0.87)
        case .swim:
            return Color(red: 0.0, green: 0.78, blue: 0.85)
        case .hiit:
            return Color(red: 1.0, green: 0.23, blue: 0.19)
        }
    }
    
    private var dayLetter: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return String(formatter.string(from: date).prefix(1))
    }
    
    private var dayLetterBackground: Color {
        if isSelected {
            return Color.accentColor
        } else if isToday {
            return Color.accentColor.opacity(0.15)
        } else {
            return Color.primary.opacity(0.06)
        }
    }
    
    private var dayLetterColor: Color {
        if isSelected {
            return .white
        } else if isToday {
            return .primary
        } else {
            return .primary.opacity(0.6)
        }
    }
    
    private var selectionBackground: Color {
        isSelected ? Color.accentColor.opacity(0.08) : Color.clear
    }
    
    private var indicatorBackground: Color {
        if isSelected {
            return Color.accentColor.opacity(0.1)
        }
        return Color.primary.opacity(0.04)
    }
    
    private var indicatorBorder: Color {
        if isToday {
            return Color.accentColor.opacity(0.3)
        } else {
            return Color.primary.opacity(0.1)
        }
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

private struct WeeklyOverviewPreviewWrapper: View {
    @State private var selection = Calendar.current.startOfDay(for: Date())
    
    var body: some View {
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
        
        WeeklyOverviewComponent(
            workouts: sampleWorkouts,
            selectedDate: $selection,
            onSelectDate: { selection = Calendar.current.startOfDay(for: $0) }
        )
        .padding()
    }
}

#Preview {
    WeeklyOverviewPreviewWrapper()
}
