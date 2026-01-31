import SwiftUI

struct SetPreferencesView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var topicHour = 18
    @State private var topicMinute = 30
    @State private var weeklyGoalHours: Double = 7
    @State private var relationshipStartDate = Date()
    @State private var hasRelationshipDate = false
    @State private var isSaving = false
    @State private var showSavedConfirmation = false

    @State private var contentOpacity: Double = 0
    @State private var contentOffset: CGFloat = 20

    /// Optional callback when preferences are saved (used during onboarding flow).
    var onSaved: (() -> Void)?

    /// Whether the view is presented inside the settings screen.
    var isInSettings: Bool = false

    var body: some View {
        ScrollView {
            VStack(spacing: TandemSpacing.lg) {
                // MARK: - Header
                if !isInSettings {
                    headerSection
                        .padding(.top, TandemSpacing.xl)
                }

                // MARK: - Daily Topic Time
                dailyTopicCard
                    .padding(.horizontal, TandemSpacing.xl)

                // MARK: - Weekly Goal
                weeklyGoalCard
                    .padding(.horizontal, TandemSpacing.xl)

                // MARK: - Relationship Date
                relationshipDateCard
                    .padding(.horizontal, TandemSpacing.xl)

                // MARK: - Save Button
                saveButton
                    .padding(.horizontal, TandemSpacing.xl)
                    .padding(.top, TandemSpacing.sm)

                // MARK: - Skip (onboarding only)
                if !isInSettings {
                    skipButton
                        .padding(.bottom, TandemSpacing.lg)
                }

                Spacer(minLength: TandemSpacing.xl)
            }
            .opacity(contentOpacity)
            .offset(y: contentOffset)
        }
        .background(TandemColors.background.ignoresSafeArea())
        .navigationTitle(isInSettings ? "Preferences" : "")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.1)) {
                contentOpacity = 1.0
                contentOffset = 0
            }
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(spacing: TandemSpacing.sm) {
            ZStack {
                Circle()
                    .fill(TandemColors.accent.opacity(0.15))
                    .frame(width: 88, height: 88)

                Image(systemName: "slider.horizontal.3")
                    .font(.system(size: 36))
                    .foregroundStyle(
                        LinearGradient(
                            gradient: Gradient(colors: [TandemColors.accent, TandemColors.primary]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            .padding(.bottom, TandemSpacing.xs)

            Text("Set Your Preferences")
                .font(TandemFonts.title)
                .foregroundColor(TandemColors.textPrimary)

            Text("Customize Tandem to fit your rhythm as a couple")
                .font(TandemFonts.body)
                .foregroundColor(TandemColors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, TandemSpacing.xl)
        }
    }

    // MARK: - Daily Topic Time Card

    private var dailyTopicCard: some View {
        VStack(alignment: .leading, spacing: TandemSpacing.md) {
            HStack(spacing: TandemSpacing.sm) {
                Image(systemName: "bell.badge.fill")
                    .font(.system(size: 18))
                    .foregroundColor(TandemColors.primary)

                Text("Daily Topic Time")
                    .font(TandemFonts.headline)
                    .foregroundColor(TandemColors.textPrimary)
            }

            Text("When should we send your daily conversation topic?")
                .font(TandemFonts.caption)
                .foregroundColor(TandemColors.textSecondary)

            HStack {
                Spacer()

                // Hour Picker
                VStack(spacing: TandemSpacing.xs) {
                    Text("Hour")
                        .font(TandemFonts.caption)
                        .foregroundColor(TandemColors.textSecondary)

                    Picker("Hour", selection: $topicHour) {
                        ForEach(0..<24, id: \.self) { hour in
                            Text(formattedHour(hour))
                                .tag(hour)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(width: 80, height: 100)
                    .clipped()
                }

                Text(":")
                    .font(.system(size: 24, weight: .bold, design: .monospaced))
                    .foregroundColor(TandemColors.textPrimary)
                    .padding(.top, TandemSpacing.md)

                // Minute Picker
                VStack(spacing: TandemSpacing.xs) {
                    Text("Min")
                        .font(TandemFonts.caption)
                        .foregroundColor(TandemColors.textSecondary)

                    Picker("Minute", selection: $topicMinute) {
                        ForEach([0, 15, 30, 45], id: \.self) { minute in
                            Text(String(format: "%02d", minute))
                                .tag(minute)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(width: 80, height: 100)
                    .clipped()
                }

                Spacer()
            }

            // Friendly time display
            HStack {
                Spacer()
                Text(friendlyTimeDescription)
                    .font(TandemFonts.caption)
                    .foregroundColor(TandemColors.secondary)
                    .animation(.easeInOut(duration: 0.2), value: topicHour)
                    .animation(.easeInOut(duration: 0.2), value: topicMinute)
                Spacer()
            }
        }
        .tandemCard()
    }

    // MARK: - Weekly Goal Card

    private var weeklyGoalCard: some View {
        VStack(alignment: .leading, spacing: TandemSpacing.md) {
            HStack(spacing: TandemSpacing.sm) {
                Image(systemName: "clock.badge.checkmark.fill")
                    .font(.system(size: 18))
                    .foregroundColor(TandemColors.secondary)

                Text("Weekly \"Our Time\" Goal")
                    .font(TandemFonts.headline)
                    .foregroundColor(TandemColors.textPrimary)
            }

            Text("How many hours per week do you want to spend on quality time together?")
                .font(TandemFonts.caption)
                .foregroundColor(TandemColors.textSecondary)

            // Goal display
            HStack {
                Spacer()
                Text("\(Int(weeklyGoalHours))")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            gradient: Gradient(colors: [TandemColors.secondary, TandemColors.primary]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )

                Text(Int(weeklyGoalHours) == 1 ? "hour" : "hours")
                    .font(TandemFonts.headline)
                    .foregroundColor(TandemColors.textSecondary)
                    .padding(.top, TandemSpacing.sm)
                Spacer()
            }
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: weeklyGoalHours)

            // Slider
            VStack(spacing: TandemSpacing.xs) {
                Slider(
                    value: $weeklyGoalHours,
                    in: 1...14,
                    step: 1
                )
                .tint(TandemColors.secondary)

                HStack {
                    Text("1 hr")
                        .font(TandemFonts.caption)
                        .foregroundColor(TandemColors.textSecondary)
                    Spacer()
                    Text("14 hrs")
                        .font(TandemFonts.caption)
                        .foregroundColor(TandemColors.textSecondary)
                }
            }

            // Encouraging message
            Text(weeklyGoalMessage)
                .font(TandemFonts.caption)
                .foregroundColor(TandemColors.accent)
                .frame(maxWidth: .infinity)
                .multilineTextAlignment(.center)
                .animation(.easeInOut(duration: 0.2), value: weeklyGoalHours)
        }
        .tandemCard()
    }

    // MARK: - Relationship Date Card

    private var relationshipDateCard: some View {
        VStack(alignment: .leading, spacing: TandemSpacing.md) {
            HStack(spacing: TandemSpacing.sm) {
                Image(systemName: "calendar.badge.plus")
                    .font(.system(size: 18))
                    .foregroundColor(TandemColors.accent)

                Text("Relationship Start Date")
                    .font(TandemFonts.headline)
                    .foregroundColor(TandemColors.textPrimary)

                Spacer()

                Text("Optional")
                    .font(TandemFonts.caption)
                    .foregroundColor(TandemColors.textSecondary)
                    .padding(.horizontal, TandemSpacing.sm)
                    .padding(.vertical, TandemSpacing.xs)
                    .background(TandemColors.textSecondary.opacity(0.1))
                    .cornerRadius(TandemCornerRadius.small)
            }

            Text("We will celebrate milestones with you!")
                .font(TandemFonts.caption)
                .foregroundColor(TandemColors.textSecondary)

            Toggle(isOn: $hasRelationshipDate.animation(.spring(response: 0.3, dampingFraction: 0.8))) {
                Text("I know our start date")
                    .font(TandemFonts.body)
                    .foregroundColor(TandemColors.textPrimary)
            }
            .tint(TandemColors.accent)

            if hasRelationshipDate {
                DatePicker(
                    "Start Date",
                    selection: $relationshipStartDate,
                    in: ...Date(),
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
                .tint(TandemColors.primary)
                .transition(.asymmetric(
                    insertion: .opacity.combined(with: .scale(scale: 0.95)),
                    removal: .opacity
                ))
            }
        }
        .tandemCard()
    }

    // MARK: - Save Button

    private var saveButton: some View {
        Button(action: savePreferences) {
            HStack(spacing: TandemSpacing.sm) {
                if isSaving {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.9)
                } else if showSavedConfirmation {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 18))
                    Text("Saved!")
                } else {
                    Text(isInSettings ? "Save Preferences" : "Save & Continue")
                    Image(systemName: "arrow.right")
                        .font(.system(size: 14, weight: .semibold))
                }
            }
            .tandemButton()
        }
        .disabled(isSaving)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSaving)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: showSavedConfirmation)
    }

    // MARK: - Skip Button

    private var skipButton: some View {
        Button {
            onSaved?()
        } label: {
            Text("Skip for now")
                .font(TandemFonts.body)
                .foregroundColor(TandemColors.textSecondary)
        }
    }

    // MARK: - Helpers

    private func formattedHour(_ hour: Int) -> String {
        let period = hour >= 12 ? "PM" : "AM"
        let displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour)
        return "\(displayHour) \(period)"
    }

    private var friendlyTimeDescription: String {
        let period = topicHour >= 12 ? "PM" : "AM"
        let displayHour = topicHour == 0 ? 12 : (topicHour > 12 ? topicHour - 12 : topicHour)
        let minuteStr = String(format: "%02d", topicMinute)
        return "Your daily topic arrives at \(displayHour):\(minuteStr) \(period)"
    }

    private var weeklyGoalMessage: String {
        let hours = Int(weeklyGoalHours)
        switch hours {
        case 1...3:
            return "A little goes a long way. Quality over quantity!"
        case 4...7:
            return "A great balance of togetherness and independence."
        case 8...10:
            return "You two really value your time together!"
        case 11...14:
            return "Love this commitment to each other!"
        default:
            return ""
        }
    }

    // MARK: - Actions

    private func savePreferences() {
        guard !isSaving else { return }
        isSaving = true

        // Schedule notifications (synchronous calls)
        NotificationService.shared.requestPermission()
        NotificationService.shared.scheduleDailyTopicReminder(
            hour: topicHour,
            minute: topicMinute
        )
        NotificationService.shared.scheduleWeeklySummaryReminder()

        Task {
            await MainActor.run {
                isSaving = false
                showSavedConfirmation = true
            }

            // Brief pause to show confirmation, then proceed
            try? await Task.sleep(nanoseconds: 800_000_000)

            await MainActor.run {
                if isInSettings {
                    dismiss()
                } else {
                    onSaved?()
                }
            }
        }
    }
}

#Preview("Onboarding") {
    SetPreferencesView(onSaved: {})
}

#Preview("Settings") {
    NavigationStack {
        SetPreferencesView(isInSettings: true)
    }
}
