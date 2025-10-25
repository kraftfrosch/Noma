//
//  WorkoutPlanView.swift
//  Noma
//
//  Created by Joshua Kraft on 25.10.25.
//

import SwiftUI

struct WorkoutPlanView: View {
    @State private var dataManager = WorkoutDataManager()
    
    var body: some View {
        NavigationStack {
            if dataManager.isLoading {
                ProgressView("Loading workouts...")
            } else if let error = dataManager.error {
                ContentUnavailableView(
                    "Unable to Load Workouts",
                    systemImage: "exclamationmark.triangle",
                    description: Text(error.localizedDescription)
                )
            } else {
                ScrollView {
                    LazyVStack(spacing: 20) {
                        WeeklyOverviewComponent(workouts: dataManager.workouts)
                            .padding(.horizontal, 16)
                            .padding(.top, 16)
                        
                        // Grouped workouts by date
                        ForEach(groupedDates, id: \.date) { dateGroup in
                            WorkoutDateSection(
                                date: dateGroup.date,
                                workouts: dateGroup.workouts,
                                dataManager: dataManager
                            )
                            .padding(.horizontal, 16)
                        }
                        .padding(.bottom, 32)
                    }
                }
                .background(Color(.systemGroupedBackground))
                .navigationTitle("Training Plan")
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        AIAssistantButton()
                    }
                }
            }
        }
    }
    
    private var groupedDates: [(date: Date, workouts: [Workout])] {
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withFullDate, .withDashSeparatorInDate]
        
        // Get date range for the planning horizon starting from today
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let endDate = calendar.date(byAdding: .day, value: 14, to: today) ?? today
        
        // Generate all dates in range
        var allDates: [Date] = []
        var currentDate = today
        while currentDate <= endDate {
            allDates.append(currentDate)
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        }
        
        // Map dates to workouts (empty array if no workouts)
        return allDates.map { date in
            let workoutsForDate = dataManager.workouts(for: date)
            return (date: date, workouts: workoutsForDate)
        }
    }
}

struct WorkoutDateSection: View {
    let date: Date
    let workouts: [Workout]
    let dataManager: WorkoutDataManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Date header
            Text(dateDisplay)
                .font(.title3.weight(.semibold))
                .foregroundStyle(.primary)
            
            if workouts.isEmpty {
                RestDayCardView()
            } else {
                // Group by time slot
                ForEach(TimeSlot.allCases, id: \.self) { slot in
                    let slotWorkouts = workouts.filter { $0.timeSlot == slot }
                    if !slotWorkouts.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(slot.displayName)
                                .font(.caption.weight(.medium))
                                .foregroundStyle(.secondary)
                                .textCase(.uppercase)
                                .padding(.leading, 4)
                            
                            ForEach(slotWorkouts) { workout in
                                NavigationLink(destination: WorkoutDetailView(workout: workout)) {
                                    WorkoutCardView(workout: workout)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
            }
        }
    }
    
    private var dateDisplay: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        
        if Calendar.current.isDateInToday(date) {
            return "Today"
        } else if Calendar.current.isDateInTomorrow(date) {
            return "Tomorrow"
        } else if Calendar.current.isDateInYesterday(date) {
            return "Yesterday"
        }
        
        return formatter.string(from: date)
    }
}

#Preview {
    WorkoutPlanView()
}

