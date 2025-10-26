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
    private let headerVisibilityBuffer: CGFloat = 32
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
                                            WorkoutDateSection(
                                                date: dateGroup.date,
                                                workouts: dateGroup.workouts,
                                                dataManager: dataManager
                                            )
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 12)
                                            .background(
                                                GeometryReader { sectionGeometry in
                                                    let frame = sectionGeometry.frame(in: .named("workoutScroll"))
                                                    Color.clear.preference(
                                                        key: WorkoutDayMetricsPreferenceKey.self,
                                                        value: [dateGroup.date: WorkoutDayMetrics(top: frame.minY, bottom: frame.maxY)]
                                                    )
                                                }
                                            )
                                            .id(dateGroup.date)
                                        }
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
                        .onPreferenceChange(WorkoutDayMetricsPreferenceKey.self) { values in
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
        let headerCompensation = effectiveHeaderHeight
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
    
    private func updateSelection(with metrics: [Date: WorkoutDayMetrics]) {
        guard !isProgrammaticScroll else { return }
        guard let newDate = topVisibleDate(from: metrics) else { return }
        if !Calendar.current.isDate(newDate, inSameDayAs: selectedDate) {
            selectedDate = Calendar.current.startOfDay(for: newDate)
        }
    }
    
    private func topVisibleDate(from metrics: [Date: WorkoutDayMetrics]) -> Date? {
        guard !metrics.isEmpty else { return nil }
        let selectionLine = effectiveHeaderHeight
        let sorted = metrics.sorted { $0.value.top < $1.value.top }
        if let intersecting = sorted.first(where: { $0.value.top <= selectionLine && $0.value.bottom > selectionLine }) {
            return intersecting.key
        }
        if let next = sorted.first(where: { $0.value.top > selectionLine }) {
            return next.key
        }
        return sorted.last?.key
    }

    private var effectiveHeaderHeight: CGFloat {
        let measured = headerHeight > 0 ? headerHeight : 140
        return measured + headerVisibilityBuffer
    }
}

private struct WeeklyOverviewHeightPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

private struct WorkoutDayMetrics: Equatable {
    let top: CGFloat
    let bottom: CGFloat
}

private struct WorkoutDayMetricsPreferenceKey: PreferenceKey {
    static var defaultValue: [Date: WorkoutDayMetrics] = [:]
    
    static func reduce(value: inout [Date: WorkoutDayMetrics], nextValue: () -> [Date: WorkoutDayMetrics]) {
        value.merge(nextValue(), uniquingKeysWith: { $1 })
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
