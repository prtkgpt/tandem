import SwiftUI

struct DateNightView: View {
    @EnvironmentObject var appViewModel: AppViewModel

    @State private var dateNights: [DateNight] = []
    @State private var isLoading = true
    @State private var showIdeaForm = false
    @State private var newIdeas: [(idea: String, budget: String)] = [
        (idea: "", budget: ""),
        (idea: "", budget: ""),
        (idea: "", budget: ""),
    ]
    @State private var isSubmitting = false

    private var activeDateNight: DateNight? {
        dateNights.first { $0.status == "planning" || $0.status == "scheduled" }
    }

    private var pastDateNights: [DateNight] {
        dateNights.filter { $0.status == "completed" }
    }

    private var currentUserId: String {
        appViewModel.currentUser?.id ?? ""
    }

    private var myIdeas: [DateIdea] {
        activeDateNight?.ideas.filter { $0.userId == currentUserId } ?? []
    }

    private var partnerIdeas: [DateIdea] {
        activeDateNight?.ideas.filter { $0.userId != currentUserId } ?? []
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: TandemSpacing.lg) {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: TandemColors.dateNightColor))
                            .padding(.top, 60)
                    } else if let active = activeDateNight {
                        dateNightHeader
                        dateNightContent(active)
                    } else {
                        emptyState
                    }

                    if !pastDateNights.isEmpty {
                        pastDateNightsSection
                    }
                }
                .padding(.bottom, TandemSpacing.xl)
            }
            .background(TandemColors.background.ignoresSafeArea())
            .refreshable { await loadDateNights() }
            .task { await loadDateNights() }
        }
    }

    // MARK: - Header

    private var dateNightHeader: some View {
        ZStack(alignment: .bottomLeading) {
            LinearGradient(
                colors: [
                    TandemColors.dateNightColor.opacity(0.15),
                    TandemColors.primary.opacity(0.06),
                    TandemColors.background,
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .frame(height: 120)

            VStack(alignment: .leading, spacing: TandemSpacing.xs) {
                Text("Date Night")
                    .font(TandemFonts.largeTitle)
                    .foregroundColor(TandemColors.textPrimary)

                Text("Plan something special together")
                    .font(TandemFonts.body)
                    .foregroundColor(TandemColors.dateNightColor)
            }
            .padding(.horizontal, TandemSpacing.md)
            .padding(.bottom, TandemSpacing.md)
        }
    }

    // MARK: - Active Date Night

    @ViewBuilder
    private func dateNightContent(_ dateNight: DateNight) -> some View {
        VStack(spacing: TandemSpacing.md) {
            // Scheduled / confirmed state
            if dateNight.status == "scheduled", let idea = dateNight.agreedIdea {
                VStack(spacing: TandemSpacing.sm) {
                    ZStack {
                        Circle()
                            .fill(TandemColors.dateNightColor.opacity(0.15))
                            .frame(width: 64, height: 64)
                        Image(systemName: "sparkles")
                            .font(.system(size: 28))
                            .foregroundColor(TandemColors.dateNightColor)
                    }

                    Text("It's a date!")
                        .font(TandemFonts.title)
                        .foregroundColor(TandemColors.textPrimary)

                    Text(idea)
                        .font(TandemFonts.headline)
                        .foregroundColor(TandemColors.textSecondary)

                    if let date = dateNight.scheduledDate {
                        Text(date)
                            .font(TandemFonts.callout)
                            .foregroundColor(TandemColors.dateNightColor)
                            .padding(.horizontal, TandemSpacing.sm)
                            .padding(.vertical, TandemSpacing.xs)
                            .background(
                                Capsule().fill(TandemColors.dateNightColor.opacity(0.10))
                            )
                    }
                }
                .sectionCard(color: TandemColors.dateNightColor)
                .padding(.horizontal, TandemSpacing.md)
            }

            // Planning phase
            if dateNight.status == "planning" {
                if myIdeas.isEmpty {
                    ideaSubmissionForm(dateNight)
                } else if partnerIdeas.isEmpty {
                    waitingForPartner
                } else {
                    ideaSelectionView(dateNight)
                }
            }
        }
    }

    // MARK: - Idea Submission

    private func ideaSubmissionForm(_ dateNight: DateNight) -> some View {
        VStack(alignment: .leading, spacing: TandemSpacing.md) {
            HStack(spacing: TandemSpacing.sm) {
                Image(systemName: "lightbulb.fill")
                    .iconBadge(color: TandemColors.dateNightColor)
                VStack(alignment: .leading, spacing: TandemSpacing.xxs) {
                    Text("Share your date ideas")
                        .font(TandemFonts.headline)
                        .foregroundColor(TandemColors.textPrimary)
                    Text("Your partner won't see them until they submit theirs!")
                        .font(TandemFonts.caption)
                        .foregroundColor(TandemColors.textSecondary)
                }
            }

            ForEach(0..<3, id: \.self) { idx in
                VStack(alignment: .leading, spacing: TandemSpacing.xs) {
                    Text("Idea \(idx + 1)\(idx == 0 ? " *" : "")")
                        .font(TandemFonts.captionBold)
                        .foregroundColor(TandemColors.textSecondary)
                    HStack(spacing: TandemSpacing.sm) {
                        TextField("What should we do?", text: Binding(
                            get: { newIdeas[idx].idea },
                            set: { newIdeas[idx].idea = $0 }
                        ))
                        .font(TandemFonts.body)
                        .padding(TandemSpacing.sm)
                        .background(
                            RoundedRectangle(cornerRadius: TandemCornerRadius.small)
                                .fill(TandemColors.background)
                        )

                        TextField("$", text: Binding(
                            get: { newIdeas[idx].budget },
                            set: { newIdeas[idx].budget = $0 }
                        ))
                        .font(TandemFonts.body)
                        .keyboardType(.decimalPad)
                        .padding(TandemSpacing.sm)
                        .background(
                            RoundedRectangle(cornerRadius: TandemCornerRadius.small)
                                .fill(TandemColors.background)
                        )
                        .frame(width: 70)
                    }
                }
            }

            Button {
                Task { await submitIdeas(dateNightId: dateNight.id) }
            } label: {
                HStack(spacing: TandemSpacing.sm) {
                    if isSubmitting {
                        ProgressView().tint(.white).scaleEffect(0.8)
                    }
                    Text(isSubmitting ? "Submitting..." : "Submit Ideas")
                }
                .font(TandemFonts.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, TandemSpacing.md)
                .background(
                    LinearGradient(
                        colors: [TandemColors.dateNightColor, TandemColors.primary],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(TandemCornerRadius.button)
                .shadow(
                    color: TandemColors.dateNightColor.opacity(0.3),
                    radius: 8, x: 0, y: 4
                )
            }
            .disabled(newIdeas[0].idea.trimmingCharacters(in: .whitespaces).isEmpty || isSubmitting)
            .opacity(newIdeas[0].idea.trimmingCharacters(in: .whitespaces).isEmpty ? 0.6 : 1.0)
        }
        .sectionCard(color: TandemColors.dateNightColor)
        .padding(.horizontal, TandemSpacing.md)
    }

    // MARK: - Waiting for Partner

    private var waitingForPartner: some View {
        VStack(spacing: TandemSpacing.md) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: TandemColors.dateNightColor))

            Text("Waiting for \(appViewModel.partnerName ?? "your partner")...")
                .font(TandemFonts.headline)
                .foregroundColor(TandemColors.textPrimary)

            Text("You've submitted your ideas. Once they submit theirs, you'll see the matches!")
                .font(TandemFonts.body)
                .foregroundColor(TandemColors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(TandemSpacing.xl)
        .frame(maxWidth: .infinity)
        .background(TandemColors.dateNightColor.opacity(0.05))
        .cornerRadius(TandemCornerRadius.card)
        .padding(.horizontal, TandemSpacing.md)
    }

    // MARK: - Idea Selection

    private func ideaSelectionView(_ dateNight: DateNight) -> some View {
        VStack(alignment: .leading, spacing: TandemSpacing.md) {
            HStack(spacing: TandemSpacing.sm) {
                Image(systemName: "hand.thumbsup.fill")
                    .iconBadge(color: TandemColors.dateNightColor)
                Text("Pick your favorite!")
                    .font(TandemFonts.headline)
                    .foregroundColor(TandemColors.textPrimary)
            }

            ForEach(dateNight.ideas) { idea in
                Button {
                    Task { await agreeOnIdea(dateNightId: dateNight.id, idea: idea) }
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: TandemSpacing.xs) {
                            Text(idea.idea)
                                .font(TandemFonts.callout)
                                .foregroundColor(TandemColors.textPrimary)
                            HStack(spacing: TandemSpacing.sm) {
                                Text("by \(idea.userId == currentUserId ? "You" : appViewModel.partnerName ?? "Partner")")
                                    .font(TandemFonts.caption)
                                    .foregroundColor(TandemColors.textSecondary)
                                if let budget = idea.budget {
                                    Text("$\(Int(budget))")
                                        .font(TandemFonts.captionBold)
                                        .foregroundColor(TandemColors.dateNightColor)
                                }
                            }
                        }
                        Spacer()
                        Image(systemName: "checkmark.circle")
                            .font(.system(size: 22))
                            .foregroundColor(TandemColors.dateNightColor)
                    }
                    .padding(TandemSpacing.md)
                    .background(TandemColors.dateNightColor.opacity(0.06))
                    .cornerRadius(TandemCornerRadius.button)
                }
            }
        }
        .sectionCard(color: TandemColors.dateNightColor)
        .padding(.horizontal, TandemSpacing.md)
    }

    // MARK: - Past Date Nights

    private var pastDateNightsSection: some View {
        VStack(alignment: .leading, spacing: TandemSpacing.sm) {
            HStack(spacing: TandemSpacing.sm) {
                Image(systemName: "clock.arrow.circlepath")
                    .iconBadge(color: TandemColors.textSecondary, size: 36)
                Text("Past Date Nights")
                    .font(TandemFonts.headline)
                    .foregroundColor(TandemColors.textSecondary)
            }
            .padding(.horizontal, TandemSpacing.md)

            ForEach(pastDateNights) { dn in
                HStack(spacing: TandemSpacing.md) {
                    Image(systemName: "sparkles")
                        .foregroundColor(TandemColors.dateNightColor)
                    VStack(alignment: .leading, spacing: TandemSpacing.xxs) {
                        Text(dn.agreedIdea ?? "Date Night")
                            .font(TandemFonts.callout)
                            .foregroundColor(TandemColors.textPrimary)
                        if let date = dn.scheduledDate {
                            Text(date)
                                .font(TandemFonts.caption)
                                .foregroundColor(TandemColors.textSecondary)
                        }
                    }
                    Spacer()
                }
                .tandemCard()
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
                    .fill(TandemColors.dateNightColor.opacity(0.12))
                    .frame(width: 100, height: 100)
                Image(systemName: "sparkles")
                    .font(.system(size: 44))
                    .foregroundColor(TandemColors.dateNightColor)
            }

            VStack(spacing: TandemSpacing.sm) {
                Text("Plan a Date Night")
                    .font(TandemFonts.title)
                    .foregroundColor(TandemColors.textPrimary)

                Text("Both of you submit ideas, see what matches, and pick a winner!")
                    .font(TandemFonts.body)
                    .foregroundColor(TandemColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, TandemSpacing.lg)
            }

            Button {
                Task { await createDateNight() }
            } label: {
                Text("Start Planning")
                    .font(TandemFonts.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, TandemSpacing.md)
                    .background(
                        LinearGradient(
                            colors: [TandemColors.dateNightColor, TandemColors.primary],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(TandemCornerRadius.button)
                    .shadow(
                        color: TandemColors.dateNightColor.opacity(0.3),
                        radius: 8, x: 0, y: 4
                    )
            }
            .padding(.horizontal, TandemSpacing.xl)
        }
    }

    // MARK: - API Calls

    private func loadDateNights() async {
        do {
            let result = try await APIService.shared.getDateNights()
            dateNights = result.dateNights
        } catch {
            print("Failed to load date nights: \(error)")
        }
        isLoading = false
    }

    private func createDateNight() async {
        do {
            let result = try await APIService.shared.createDateNight()
            dateNights.insert(result.dateNight, at: 0)
        } catch {
            print("Failed to create date night: \(error)")
        }
    }

    private func submitIdeas(dateNightId: String) async {
        isSubmitting = true
        let ideas = newIdeas.compactMap { item -> [String: Any]? in
            let trimmed = item.idea.trimmingCharacters(in: .whitespaces)
            guard !trimmed.isEmpty else { return nil }
            var dict: [String: Any] = ["idea": trimmed]
            if let budget = Double(item.budget) { dict["budget"] = budget }
            return dict
        }
        guard !ideas.isEmpty else { return }
        do {
            let result = try await APIService.shared.submitIdeas(dateNightId: dateNightId, ideas: ideas)
            if let idx = dateNights.firstIndex(where: { $0.id == dateNightId }) {
                dateNights[idx] = result.dateNight
            }
        } catch {
            print("Failed to submit ideas: \(error)")
        }
        isSubmitting = false
    }

    private func agreeOnIdea(dateNightId: String, idea: DateIdea) async {
        do {
            let result = try await APIService.shared.updateDateNight(
                id: dateNightId,
                agreedIdea: idea.idea,
                agreedBudget: idea.budget,
                scheduledDate: nil,
                status: "scheduled"
            )
            if let idx = dateNights.firstIndex(where: { $0.id == dateNightId }) {
                dateNights[idx] = result.dateNight
            }
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        } catch {
            print("Failed to agree on idea: \(error)")
        }
    }
}
