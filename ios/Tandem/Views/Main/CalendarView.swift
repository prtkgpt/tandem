import SwiftUI

struct CalendarView: View {
    @EnvironmentObject var appViewModel: AppViewModel

    @State private var events: [CoupleEvent] = []
    @State private var isLoading = true
    @State private var showNewEvent = false

    // New event form
    @State private var newTitle = ""
    @State private var newEmoji = "\u{2764}\u{FE0F}"
    @State private var newDate = Date()
    @State private var newType = "date"
    @State private var newNotes = ""

    private let eventTypes: [(id: String, label: String, emoji: String)] = [
        ("date", "Date", "\u{2764}\u{FE0F}"),
        ("anniversary", "Anniversary", "\u{1F48D}"),
        ("birthday", "Birthday", "\u{1F382}"),
        ("trip", "Trip", "\u{2708}\u{FE0F}"),
        ("activity", "Activity", "\u{1F3AF}"),
        ("milestone", "Milestone", "\u{2B50}"),
    ]

    private var upcomingEvents: [CoupleEvent] {
        let now = Date()
        return events.filter { parseDate($0.eventDate) >= now }
    }

    private var pastEvents: [CoupleEvent] {
        let now = Date()
        return events.filter { parseDate($0.eventDate) < now }.reversed()
    }

    private var nextEvent: CoupleEvent? {
        upcomingEvents.first
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: TandemSpacing.lg) {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: TandemColors.calendarColor))
                            .padding(.top, 60)
                    } else if events.isEmpty {
                        emptyState
                    } else {
                        calendarHeader

                        // Countdown card
                        if let next = nextEvent {
                            countdownCard(next)
                        }

                        // Upcoming
                        if !upcomingEvents.isEmpty {
                            eventsSection(title: "Coming Up", events: upcomingEvents, showDaysUntil: true)
                        }

                        // Past
                        if !pastEvents.isEmpty {
                            eventsSection(title: "Memories", events: Array(pastEvents.prefix(10)), showDaysUntil: false)
                        }
                    }
                }
                .padding(.bottom, TandemSpacing.xl)
            }
            .background(TandemColors.background.ignoresSafeArea())
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showNewEvent = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 22))
                            .foregroundColor(TandemColors.calendarColor)
                    }
                }
            }
            .refreshable { await loadEvents() }
            .task { await loadEvents() }
            .sheet(isPresented: $showNewEvent) { newEventSheet }
        }
    }

    // MARK: - Header

    private var calendarHeader: some View {
        ZStack(alignment: .bottomLeading) {
            LinearGradient(
                colors: [
                    TandemColors.calendarColor.opacity(0.12),
                    TandemColors.primary.opacity(0.06),
                    TandemColors.background,
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .frame(height: 120)

            VStack(alignment: .leading, spacing: TandemSpacing.xs) {
                Text("Our Moments")
                    .font(TandemFonts.largeTitle)
                    .foregroundColor(TandemColors.textPrimary)

                Text("\(events.count) moment\(events.count == 1 ? "" : "s") together")
                    .font(TandemFonts.body)
                    .foregroundColor(TandemColors.calendarColor)
            }
            .padding(.horizontal, TandemSpacing.md)
            .padding(.bottom, TandemSpacing.md)
        }
    }

    // MARK: - Countdown Card

    private func countdownCard(_ event: CoupleEvent) -> some View {
        let days = daysUntil(event.eventDate)

        return VStack(spacing: TandemSpacing.md) {
            Text(event.emoji)
                .font(.system(size: 40))

            if days == 0 {
                Text("Today!")
                    .font(TandemFonts.title)
                    .foregroundColor(TandemColors.calendarColor)
            } else {
                HStack(alignment: .firstTextBaseline, spacing: TandemSpacing.xs) {
                    Text("\(days)")
                        .font(.system(size: 44, weight: .bold, design: .rounded))
                        .foregroundColor(TandemColors.calendarColor)
                    Text("day\(days == 1 ? "" : "s") until")
                        .font(TandemFonts.body)
                        .foregroundColor(TandemColors.textSecondary)
                }
            }

            Text(event.title)
                .font(TandemFonts.headline)
                .foregroundColor(TandemColors.textPrimary)

            Text(formatEventDate(event.eventDate))
                .font(TandemFonts.caption)
                .foregroundColor(TandemColors.calendarColor)
                .padding(.horizontal, TandemSpacing.sm)
                .padding(.vertical, TandemSpacing.xs)
                .background(
                    Capsule().fill(TandemColors.calendarColor.opacity(0.10))
                )
        }
        .frame(maxWidth: .infinity)
        .sectionCard(color: TandemColors.calendarColor)
        .padding(.horizontal, TandemSpacing.md)
    }

    // MARK: - Events List

    private func eventsSection(title: String, events: [CoupleEvent], showDaysUntil: Bool) -> some View {
        VStack(alignment: .leading, spacing: TandemSpacing.sm) {
            Text(title)
                .font(TandemFonts.headline)
                .foregroundColor(TandemColors.textSecondary)
                .padding(.horizontal, TandemSpacing.md)

            ForEach(events) { event in
                HStack(spacing: TandemSpacing.md) {
                    Text(event.emoji)
                        .font(.system(size: 24))
                        .frame(width: 40)

                    VStack(alignment: .leading, spacing: TandemSpacing.xxs) {
                        Text(event.title)
                            .font(TandemFonts.callout)
                            .foregroundColor(TandemColors.textPrimary)

                        Text(formatEventDate(event.eventDate))
                            .font(TandemFonts.caption)
                            .foregroundColor(TandemColors.textSecondary)
                    }

                    Spacer()

                    if showDaysUntil {
                        let d = daysUntil(event.eventDate)
                        Text(d == 0 ? "Today" : "\(d)d")
                            .font(TandemFonts.captionBold)
                            .foregroundColor(TandemColors.calendarColor)
                    }
                }
                .padding(TandemSpacing.md)
                .background(TandemColors.cardBackground)
                .cornerRadius(TandemCornerRadius.card)
                .shadow(
                    color: TandemShadow.soft.color,
                    radius: TandemShadow.soft.radius,
                    x: TandemShadow.soft.x,
                    y: TandemShadow.soft.y
                )
                .padding(.horizontal, TandemSpacing.md)
            }
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: TandemSpacing.lg) {
            Spacer().frame(height: TandemSpacing.xxl)

            ZStack {
                Circle()
                    .fill(TandemColors.calendarColor.opacity(0.12))
                    .frame(width: 100, height: 100)
                Image(systemName: "calendar.badge.plus")
                    .font(.system(size: 44))
                    .foregroundColor(TandemColors.calendarColor)
            }

            VStack(spacing: TandemSpacing.sm) {
                Text("Your Shared Calendar")
                    .font(TandemFonts.title)
                    .foregroundColor(TandemColors.textPrimary)

                Text("Plan dates, mark anniversaries, and count down to special moments together.")
                    .font(TandemFonts.body)
                    .foregroundColor(TandemColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, TandemSpacing.lg)
            }

            Button {
                showNewEvent = true
            } label: {
                Text("Add First Moment")
                    .font(TandemFonts.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, TandemSpacing.md)
                    .background(
                        LinearGradient(
                            colors: [TandemColors.calendarColor, TandemColors.primary],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(TandemCornerRadius.button)
                    .shadow(
                        color: TandemColors.calendarColor.opacity(0.3),
                        radius: 8, x: 0, y: 4
                    )
            }
            .padding(.horizontal, TandemSpacing.xl)
        }
    }

    // MARK: - New Event Sheet

    private var newEventSheet: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: TandemSpacing.lg) {
                    // Type picker
                    VStack(alignment: .leading, spacing: TandemSpacing.sm) {
                        Text("What kind of moment?")
                            .font(TandemFonts.captionBold)
                            .foregroundColor(TandemColors.textSecondary)

                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: TandemSpacing.sm) {
                            ForEach(eventTypes, id: \.id) { type in
                                Button {
                                    newType = type.id
                                    newEmoji = type.emoji
                                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                } label: {
                                    VStack(spacing: TandemSpacing.xs) {
                                        Text(type.emoji)
                                            .font(.system(size: 24))
                                        Text(type.label)
                                            .font(TandemFonts.micro)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, TandemSpacing.sm)
                                    .background(
                                        RoundedRectangle(cornerRadius: TandemCornerRadius.small)
                                            .fill(newType == type.id
                                                  ? TandemColors.calendarColor.opacity(0.15)
                                                  : TandemColors.background)
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: TandemCornerRadius.small)
                                            .stroke(newType == type.id ? TandemColors.calendarColor : Color.clear, lineWidth: 2)
                                    )
                                    .foregroundColor(TandemColors.textPrimary)
                                }
                            }
                        }
                    }

                    // Title
                    VStack(alignment: .leading, spacing: TandemSpacing.xs) {
                        Text("Title")
                            .font(TandemFonts.captionBold)
                            .foregroundColor(TandemColors.textSecondary)
                        TextField("e.g., Dinner at Mario's", text: $newTitle)
                            .font(TandemFonts.body)
                            .padding(TandemSpacing.sm)
                            .background(
                                RoundedRectangle(cornerRadius: TandemCornerRadius.small)
                                    .fill(TandemColors.background)
                            )
                    }

                    // Date
                    VStack(alignment: .leading, spacing: TandemSpacing.xs) {
                        Text("When?")
                            .font(TandemFonts.captionBold)
                            .foregroundColor(TandemColors.textSecondary)
                        DatePicker("", selection: $newDate, displayedComponents: [.date])
                            .datePickerStyle(.graphical)
                            .tint(TandemColors.calendarColor)
                    }

                    // Notes (optional)
                    VStack(alignment: .leading, spacing: TandemSpacing.xs) {
                        Text("Notes (optional)")
                            .font(TandemFonts.captionBold)
                            .foregroundColor(TandemColors.textSecondary)
                        TextField("Any details...", text: $newNotes, axis: .vertical)
                            .font(TandemFonts.body)
                            .lineLimit(2...4)
                            .padding(TandemSpacing.sm)
                            .background(
                                RoundedRectangle(cornerRadius: TandemCornerRadius.small)
                                    .fill(TandemColors.background)
                            )
                    }
                }
                .padding(TandemSpacing.md)
            }
            .background(TandemColors.cardBackground)
            .navigationTitle("New Moment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { showNewEvent = false }
                        .foregroundColor(TandemColors.textSecondary)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task { await createEvent() }
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(TandemColors.calendarColor)
                    .disabled(newTitle.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
        .presentationDetents([.large])
    }

    // MARK: - Date Helpers

    private func parseDate(_ isoString: String) -> Date {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.date(from: isoString) ?? Date.distantPast
    }

    private func daysUntil(_ isoString: String) -> Int {
        let date = parseDate(isoString)
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        let eventDay = cal.startOfDay(for: date)
        return max(0, cal.dateComponents([.day], from: today, to: eventDay).day ?? 0)
    }

    private func formatEventDate(_ isoString: String) -> String {
        let date = parseDate(isoString)
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }

    // MARK: - API Calls

    private func loadEvents() async {
        do {
            let result = try await APIService.shared.getEvents()
            events = result.events
        } catch {
            print("Failed to load events: \(error)")
        }
        isLoading = false
    }

    private func createEvent() async {
        let title = newTitle.trimmingCharacters(in: .whitespaces)
        guard !title.isEmpty else { return }

        let formatter = ISO8601DateFormatter()
        let dateStr = formatter.string(from: newDate)

        do {
            let result = try await APIService.shared.createEvent(
                title: title,
                emoji: newEmoji,
                eventDate: dateStr,
                eventType: newType,
                notes: newNotes.isEmpty ? nil : newNotes
            )
            events.append(result.event)
            events.sort { parseDate($0.eventDate) < parseDate($1.eventDate) }
            newTitle = ""
            newNotes = ""
            newDate = Date()
            showNewEvent = false
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        } catch {
            print("Failed to create event: \(error)")
        }
    }
}
