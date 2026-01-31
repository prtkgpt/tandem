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
                VStack(spacing: 20) {
                    if isLoading {
                        ProgressView()
                            .padding(.top, 60)
                    } else if let active = activeDateNight {
                        dateNightContent(active)
                    } else {
                        emptyState
                    }

                    // Past date nights
                    if !pastDateNights.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Past Date Nights")
                                .font(.headline)
                                .foregroundColor(Theme.textSecondary)
                                .padding(.horizontal)

                            ForEach(pastDateNights) { dn in
                                HStack {
                                    Image(systemName: "sparkles")
                                        .foregroundColor(Theme.primary)
                                    VStack(alignment: .leading) {
                                        Text(dn.agreedIdea ?? "Date Night")
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                        if let date = dn.scheduledDate {
                                            Text(date)
                                                .font(.caption)
                                                .foregroundColor(Theme.textSecondary)
                                        }
                                    }
                                    Spacer()
                                }
                                .padding()
                                .background(Color.white)
                                .cornerRadius(Theme.cardRadius)
                                .padding(.horizontal)
                            }
                        }
                    }
                }
                .padding(.vertical)
            }
            .background(Theme.background)
            .navigationTitle("Date Night")
            .refreshable { await loadDateNights() }
            .task { await loadDateNights() }
        }
    }

    // MARK: - Active Date Night

    @ViewBuilder
    private func dateNightContent(_ dateNight: DateNight) -> some View {
        VStack(spacing: 16) {
            // Status header
            if dateNight.status == "scheduled", let idea = dateNight.agreedIdea {
                VStack(spacing: 8) {
                    Image(systemName: "sparkles")
                        .font(.largeTitle)
                        .foregroundColor(Theme.primary)
                    Text("It's a date!")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text(idea)
                        .font(.headline)
                        .foregroundColor(Theme.textSecondary)
                    if let date = dateNight.scheduledDate {
                        Text(date)
                            .font(.subheadline)
                            .foregroundColor(Theme.primary)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.white)
                .cornerRadius(Theme.cardRadius)
                .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
                .padding(.horizontal)
            }

            // Idea submission
            if dateNight.status == "planning" {
                if myIdeas.isEmpty {
                    // Submit ideas form
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Share your date ideas")
                            .font(.headline)
                        Text("Submit up to 3 ideas. Your partner won't see them until they submit theirs too!")
                            .font(.subheadline)
                            .foregroundColor(Theme.textSecondary)

                        ForEach(0..<3, id: \.self) { idx in
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Idea \(idx + 1)\(idx == 0 ? " *" : "")")
                                    .font(.caption)
                                    .foregroundColor(Theme.textSecondary)
                                HStack {
                                    TextField("What should we do?", text: Binding(
                                        get: { newIdeas[idx].idea },
                                        set: { newIdeas[idx].idea = $0 }
                                    ))
                                    .textFieldStyle(.roundedBorder)

                                    TextField("$", text: Binding(
                                        get: { newIdeas[idx].budget },
                                        set: { newIdeas[idx].budget = $0 }
                                    ))
                                    .textFieldStyle(.roundedBorder)
                                    .keyboardType(.decimalPad)
                                    .frame(width: 70)
                                }
                            }
                        }

                        Button {
                            Task { await submitIdeas(dateNightId: dateNight.id) }
                        } label: {
                            HStack {
                                if isSubmitting {
                                    ProgressView().tint(.white)
                                }
                                Text(isSubmitting ? "Submitting..." : "Submit Ideas")
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Theme.primary)
                            .foregroundColor(.white)
                            .cornerRadius(Theme.buttonRadius)
                        }
                        .disabled(newIdeas[0].idea.trimmingCharacters(in: .whitespaces).isEmpty || isSubmitting)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(Theme.cardRadius)
                    .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
                    .padding(.horizontal)
                } else if partnerIdeas.isEmpty {
                    // Waiting for partner
                    VStack(spacing: 12) {
                        ProgressView()
                        Text("Waiting for \(appViewModel.partnerName ?? "your partner")...")
                            .font(.headline)
                        Text("You've submitted your ideas. Once they submit theirs, you'll see the matches!")
                            .font(.subheadline)
                            .foregroundColor(Theme.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(32)
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
                    .cornerRadius(Theme.cardRadius)
                    .padding(.horizontal)
                } else {
                    // Both submitted — show all ideas
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Pick your favorite!")
                            .font(.headline)

                        let allIdeas = dateNight.ideas
                        ForEach(allIdeas) { idea in
                            Button {
                                Task { await agreeOnIdea(dateNightId: dateNight.id, idea: idea) }
                            } label: {
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(idea.idea)
                                            .fontWeight(.medium)
                                            .foregroundColor(Theme.textPrimary)
                                        HStack {
                                            Text("by \(idea.userId == currentUserId ? "You" : appViewModel.partnerName ?? "Partner")")
                                                .font(.caption)
                                                .foregroundColor(Theme.textSecondary)
                                            if let budget = idea.budget {
                                                Text("$\(Int(budget))")
                                                    .font(.caption)
                                                    .fontWeight(.semibold)
                                                    .foregroundColor(Theme.primary)
                                            }
                                        }
                                    }
                                    Spacer()
                                    Image(systemName: "checkmark.circle")
                                        .foregroundColor(Theme.primary)
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                            }
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(Theme.cardRadius)
                    .padding(.horizontal)
                }
            }
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: "sparkles")
                .font(.system(size: 48))
                .foregroundColor(Theme.primary.opacity(0.5))
            Text("Plan a Date Night")
                .font(.title2)
                .fontWeight(.bold)
            Text("Both of you submit ideas, see what matches, and pick a winner!")
                .font(.subheadline)
                .foregroundColor(Theme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            Button {
                Task { await createDateNight() }
            } label: {
                Text("Start Planning")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Theme.primary)
                    .foregroundColor(.white)
                    .cornerRadius(Theme.buttonRadius)
            }
            .padding(.horizontal, 40)
        }
        .padding(.top, 40)
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
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        } catch {
            print("Failed to agree on idea: \(error)")
        }
    }
}
