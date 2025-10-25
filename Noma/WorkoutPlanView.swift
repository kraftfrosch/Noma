//
//  WorkoutPlanView.swift
//  Noma
//
//  Created by Joshua Kraft on 25.10.25.
//

import SwiftUI

struct WorkoutPlanView: View {
    @State private var dataManager = WorkoutDataManager()
    @State private var chatMessage = ""
    @State private var isChatActive = false
    @State private var selectedDate = Calendar.current.startOfDay(for: Date())
    @State private var isProgrammaticScroll = false
    @State private var headerHeight: CGFloat = 0
    private let headerVisibilityBuffer: CGFloat = 40
    @FocusState private var isChatInputFocused: Bool
    
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
                GeometryReader { geometry in
                    ScrollViewReader { proxy in
                        ScrollView {
                            LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                                Section {
                                    LazyVStack(spacing: 20) {
                                        // Grouped workouts by date
                                        ForEach(groupedDates, id: \.date) { dateGroup in
                                            let isSelected = Calendar.current.isDate(dateGroup.date, inSameDayAs: selectedDate)
                                            WorkoutDateSection(
                                                date: dateGroup.date,
                                                workouts: dateGroup.workouts,
                                                dataManager: dataManager
                                            )
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 12)
                                            .background(
                                                GeometryReader { sectionGeometry in
                                                    Color.clear
                                                        .preference(
                                                            key: WorkoutDayOffsetPreferenceKey.self,
                                                            value: [dateGroup.date: sectionGeometry.frame(in: .named("workoutScroll")).minY]
                                                        )
                                                }
                                            )
                                            .background(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .fill(isSelected ? Color(.secondarySystemFill) : Color.clear)
                                            )
                                            .id(dateGroup.date)
                                        }
                                        .padding(.bottom, 32)
                                    }
                                    .padding(.top, 16)
                                } header: {
                                    VStack(spacing: 0) {
                                        WeeklyOverviewComponent(
                                            workouts: dataManager.workouts,
                                            selectedDate: $selectedDate,
                                            onSelectDate: { date in
                                                scrollToDate(date, with: proxy, containerHeight: geometry.size.height)
                                            }
                                        )
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(
                                            GeometryReader { headerGeometry in
                                                Color.clear
                                                    .preference(
                                                        key: WeeklyOverviewHeightPreferenceKey.self,
                                                        value: headerGeometry.size.height
                                                    )
                                            }
                                        )
                                    }
                                    .background(.clear)
                                }
                            }
                        }
                        .coordinateSpace(name: "workoutScroll")
                        .onPreferenceChange(WorkoutDayOffsetPreferenceKey.self) { values in
                            updateSelection(with: values)
                        }
                        .onPreferenceChange(WeeklyOverviewHeightPreferenceKey.self) { newHeight in
                            if newHeight > 0 {
                                headerHeight = newHeight
                            }
                        }
                    }
                }
                .background(Color(.systemGroupedBackground))
                .navigationTitle("Training Plan")
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
        }
    }
    
    private var groupedDates: [(date: Date, workouts: [Workout])] {
        // Get date range for the planning horizon starting from the current week
        let calendar = Calendar.current
        let startDate = calendar.startOfWeek(for: Date())
        let endDate = calendar.date(byAdding: .day, value: 14, to: startDate) ?? startDate
        
        // Generate all dates in range
        var allDates: [Date] = []
        var currentDate = startDate
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

    private func scrollToDate(_ date: Date, with proxy: ScrollViewProxy, containerHeight: CGFloat) {
        guard groupedDates.contains(where: { Calendar.current.isDate($0.date, inSameDayAs: date) }) else { return }
        let normalizedDate = Calendar.current.startOfDay(for: date)
        isProgrammaticScroll = true
        selectedDate = normalizedDate
        let headerCompensation = (headerHeight > 0 ? headerHeight : 140) + headerVisibilityBuffer
        let denominator = max(containerHeight, 1)
        let anchorY = min(max(headerCompensation / denominator, 0), 1)
        let anchor = UnitPoint(x: 0.5, y: anchorY)

        withAnimation(.easeInOut) {
            proxy.scrollTo(normalizedDate, anchor: anchor)
        }

        // Allow scroll position preferences to settle before resuming automatic updates
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            isProgrammaticScroll = false
        }
    }
    
    private func updateSelection(with offsets: [Date: CGFloat]) {
        guard !isProgrammaticScroll else { return }
        guard let newDate = topVisibleDate(from: offsets, headerHeight: headerHeight) else { return }
        if !Calendar.current.isDate(newDate, inSameDayAs: selectedDate) {
            selectedDate = Calendar.current.startOfDay(for: newDate)
        }
    }
    
    private func topVisibleDate(from offsets: [Date: CGFloat], headerHeight: CGFloat) -> Date? {
        let effectiveHeaderHeight = (headerHeight > 0 ? headerHeight : 140) + headerVisibilityBuffer
        let adjustedOffsets = offsets.mapValues { $0 - effectiveHeaderHeight }
        let threshold: CGFloat = 20
        let candidates = adjustedOffsets
            .filter { $0.value > -threshold }
            .sorted { $0.value < $1.value }
        if let best = candidates.first {
            return best.key
        }
        if let closest = adjustedOffsets.min(by: { abs($0.value) < abs($1.value) }) {
            return closest.key
        }
        return nil
    }
}

private struct WorkoutDayOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: [Date: CGFloat] = [:]
    
    static func reduce(value: inout [Date: CGFloat], nextValue: () -> [Date: CGFloat]) {
        value.merge(nextValue(), uniquingKeysWith: { $1 })
    }
}

private struct WeeklyOverviewHeightPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
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
