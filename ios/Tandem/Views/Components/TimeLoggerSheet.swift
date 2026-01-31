import SwiftUI

struct TimeLoggerSheet: View {
    let onSubmit: (String, Int, Date) -> Void
    let onDismiss: () -> Void

    // MARK: - Quick Pick Activities

    private struct Activity: Identifiable {
        let id = UUID()
        let name: String
        let emoji: String
    }

    private let activities: [Activity] = [
        Activity(name: "Dinner", emoji: "🍽️"),
        Activity(name: "Walk", emoji: "🚶"),
        Activity(name: "Movie", emoji: "🎬"),
        Activity(name: "Cooking", emoji: "🍳"),
        Activity(name: "Talking", emoji: "💬"),
        Activity(name: "Other", emoji: "✨")
    ]

    // MARK: - State

    @State private var selectedActivity: String? = nil
    @State private var customActivity: String = ""
    @State private var durationMinutes: Double = 60
    @State private var date: Date = Date()
    @State private var isSubmitting: Bool = false

    // MARK: - Computed

    private var isOtherSelected: Bool {
        selectedActivity == "Other"
    }

    private var activityName: String {
        if isOtherSelected {
            return customActivity.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return selectedActivity ?? ""
    }

    private var canSubmit: Bool {
        if isOtherSelected {
            return !customActivity.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
        return selectedActivity != nil
    }

    private var formattedDuration: String {
        let hours = Int(durationMinutes) / 60
        let minutes = Int(durationMinutes) % 60
        if hours > 0 && minutes > 0 {
            return "\(hours)h \(minutes)m"
        } else if hours > 0 {
            return "\(hours)h"
        } else {
            return "\(minutes)m"
        }
    }

    // MARK: - Body

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: TandemSpacing.lg) {
                    // Activity selection
                    activitySection

                    // Custom activity field
                    if isOtherSelected {
                        customActivitySection
                    }

                    // Duration slider
                    durationSection

                    // Date picker
                    dateSection

                    // Submit button
                    submitButton
                }
                .padding(TandemSpacing.lg)
            }
            .background(TandemColors.background.ignoresSafeArea())
            .navigationTitle("Log Our Time")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        onDismiss()
                    }
                    .foregroundColor(TandemColors.textSecondary)
                }
            }
        }
    }

    // MARK: - Activity Section

    private var activitySection: some View {
        VStack(alignment: .leading, spacing: TandemSpacing.sm) {
            Text("What did you do together?")
                .font(TandemFonts.headline)
                .foregroundColor(TandemColors.textPrimary)

            LazyVGrid(
                columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ],
                spacing: TandemSpacing.sm
            ) {
                ForEach(activities) { activity in
                    activityButton(activity)
                }
            }
        }
    }

    private func activityButton(_ activity: Activity) -> some View {
        let isSelected = selectedActivity == activity.name

        return Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                if selectedActivity == activity.name {
                    selectedActivity = nil
                } else {
                    selectedActivity = activity.name
                }
            }

            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()
        } label: {
            VStack(spacing: TandemSpacing.xs) {
                Text(activity.emoji)
                    .font(.system(size: 28))

                Text(activity.name)
                    .font(TandemFonts.caption)
                    .foregroundColor(
                        isSelected ? TandemColors.primary : TandemColors.textSecondary
                    )
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, TandemSpacing.md)
            .background(
                isSelected
                    ? TandemColors.primary.opacity(0.1)
                    : TandemColors.cardBackground
            )
            .cornerRadius(TandemCornerRadius.button)
            .overlay(
                RoundedRectangle(cornerRadius: TandemCornerRadius.button)
                    .stroke(
                        isSelected ? TandemColors.primary : Color.clear,
                        lineWidth: 2
                    )
            )
            .shadow(color: Color.black.opacity(isSelected ? 0 : 0.04), radius: 4, y: 2)
        }
    }

    // MARK: - Custom Activity

    private var customActivitySection: some View {
        VStack(alignment: .leading, spacing: TandemSpacing.sm) {
            Text("What activity?")
                .font(TandemFonts.body)
                .foregroundColor(TandemColors.textSecondary)

            TextField("e.g., Board game night", text: $customActivity)
                .font(TandemFonts.body)
                .padding(TandemSpacing.md)
                .background(TandemColors.cardBackground)
                .cornerRadius(TandemCornerRadius.small)
                .shadow(color: Color.black.opacity(0.04), radius: 4, y: 2)
        }
        .transition(.opacity.combined(with: .move(edge: .top)))
    }

    // MARK: - Duration Section

    private var durationSection: some View {
        VStack(alignment: .leading, spacing: TandemSpacing.sm) {
            HStack {
                Text("Duration")
                    .font(TandemFonts.headline)
                    .foregroundColor(TandemColors.textPrimary)

                Spacer()

                Text(formattedDuration)
                    .font(TandemFonts.title)
                    .foregroundColor(TandemColors.primary)
            }

            Slider(
                value: $durationMinutes,
                in: 15...240,
                step: 15
            )
            .tint(TandemColors.primary)

            // Duration markers
            HStack {
                Text("15m")
                    .font(TandemFonts.caption)
                    .foregroundColor(TandemColors.textSecondary)
                Spacer()
                Text("4h")
                    .font(TandemFonts.caption)
                    .foregroundColor(TandemColors.textSecondary)
            }
        }
    }

    // MARK: - Date Section

    private var dateSection: some View {
        VStack(alignment: .leading, spacing: TandemSpacing.sm) {
            Text("When")
                .font(TandemFonts.headline)
                .foregroundColor(TandemColors.textPrimary)

            DatePicker(
                "",
                selection: $date,
                in: ...Date(),
                displayedComponents: .date
            )
            .datePickerStyle(.compact)
            .labelsHidden()
            .tint(TandemColors.primary)
        }
    }

    // MARK: - Submit Button

    private var submitButton: some View {
        Button(action: submit) {
            HStack(spacing: TandemSpacing.sm) {
                if isSubmitting {
                    ProgressView()
                        .tint(.white)
                } else {
                    Image(systemName: "clock.badge.checkmark")
                    Text("Log Our Time")
                }
            }
            .tandemButton()
        }
        .disabled(!canSubmit || isSubmitting)
        .opacity(canSubmit ? 1.0 : 0.5)
        .padding(.top, TandemSpacing.sm)
    }

    // MARK: - Actions

    private func submit() {
        guard canSubmit else { return }

        let impact = UINotificationFeedbackGenerator()
        impact.notificationOccurred(.success)

        isSubmitting = true
        onSubmit(activityName, Int(durationMinutes), date)
    }
}

// MARK: - Preview

#Preview {
    TimeLoggerSheet(
        onSubmit: { activity, duration, date in
            print("Logged: \(activity), \(duration)min, \(date)")
        },
        onDismiss: {
            print("Dismissed")
        }
    )
}
