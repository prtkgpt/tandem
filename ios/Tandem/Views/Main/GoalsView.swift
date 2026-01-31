import SwiftUI

struct GoalsView: View {
    @State private var goals: [SavingsGoal] = []
    @State private var isLoading = true
    @State private var showNewGoal = false
    @State private var showContribute = false
    @State private var selectedGoal: SavingsGoal?

    // New goal form
    @State private var newName = ""
    @State private var newTarget = ""
    @State private var newEmoji = "💰"
    @State private var contributeAmount = ""

    private let emojiOptions = ["💰", "🏖️", "🏠", "🚗", "💍", "🎓", "🛫", "🎁", "🏋️", "📱"]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    if isLoading {
                        ProgressView().padding(.top, 60)
                    } else if goals.isEmpty {
                        emptyState
                    } else {
                        ForEach(goals) { goal in
                            GoalCardView(goal: goal) {
                                selectedGoal = goal
                                showContribute = true
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                .padding(.vertical)
            }
            .background(TandemColors.background)
            .navigationTitle("Goals")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showNewGoal = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(TandemColors.primary)
                    }
                }
            }
            .refreshable { await loadGoals() }
            .task { await loadGoals() }
            .sheet(isPresented: $showNewGoal) { newGoalSheet }
            .sheet(isPresented: $showContribute) { contributeSheet }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: "chart.bar.fill")
                .font(.system(size: 48))
                .foregroundColor(TandemColors.primary.opacity(0.5))
            Text("Start Saving Together")
                .font(.title2)
                .fontWeight(.bold)
            Text("Create shared savings goals and track your progress as a couple.")
                .font(.subheadline)
                .foregroundColor(TandemColors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            Button {
                showNewGoal = true
            } label: {
                Text("Create First Goal")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(TandemColors.primary)
                    .foregroundColor(.white)
                    .cornerRadius(TandemCornerRadius.button)
            }
            .padding(.horizontal, 40)
        }
        .padding(.top, 40)
    }

    private var newGoalSheet: some View {
        NavigationStack {
            Form {
                Section("Goal Details") {
                    HStack {
                        Text("Emoji")
                        Spacer()
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(emojiOptions, id: \.self) { emoji in
                                    Button(emoji) {
                                        newEmoji = emoji
                                    }
                                    .font(.title2)
                                    .padding(6)
                                    .background(newEmoji == emoji ? TandemColors.primary.opacity(0.2) : Color.clear)
                                    .cornerRadius(8)
                                }
                            }
                        }
                    }
                    TextField("Goal name (e.g., Vacation Fund)", text: $newName)
                    TextField("Target amount", text: $newTarget)
                        .keyboardType(.decimalPad)
                }
            }
            .navigationTitle("New Goal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { showNewGoal = false }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        Task { await createGoal() }
                    }
                    .disabled(newName.isEmpty || newTarget.isEmpty)
                }
            }
        }
        .presentationDetents([.medium])
    }

    private var contributeSheet: some View {
        NavigationStack {
            VStack(spacing: 24) {
                if let goal = selectedGoal {
                    Text(goal.emoji)
                        .font(.system(size: 48))
                    Text(goal.name)
                        .font(.headline)
                    Text("$\(Int(goal.currentAmount)) / $\(Int(goal.targetAmount))")
                        .foregroundColor(TandemColors.textSecondary)

                    TextField("Amount", text: $contributeAmount)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(.roundedBorder)
                        .font(.title2)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)

                    Button {
                        Task { await contribute() }
                    } label: {
                        Text("Add Contribution")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(TandemColors.primary)
                            .foregroundColor(.white)
                            .cornerRadius(TandemCornerRadius.button)
                    }
                    .padding(.horizontal)
                    .disabled(contributeAmount.isEmpty)
                }
                Spacer()
            }
            .padding(.top, 32)
            .navigationTitle("Contribute")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { showContribute = false }
                }
            }
        }
        .presentationDetents([.medium])
    }

    private func loadGoals() async {
        do {
            let result = try await APIService.shared.getGoals()
            goals = result.goals
        } catch {
            print("Failed to load goals: \(error)")
        }
        isLoading = false
    }

    private func createGoal() async {
        guard let target = Double(newTarget) else { return }
        do {
            let result = try await APIService.shared.createGoal(
                name: newName, targetAmount: target, emoji: newEmoji
            )
            goals.insert(result.goal, at: 0)
            newName = ""
            newTarget = ""
            newEmoji = "💰"
            showNewGoal = false
        } catch {
            print("Failed to create goal: \(error)")
        }
    }

    private func contribute() async {
        guard let goal = selectedGoal, let amount = Double(contributeAmount) else { return }
        do {
            let result = try await APIService.shared.contribute(goalId: goal.id, amount: amount)
            if let idx = goals.firstIndex(where: { $0.id == goal.id }) {
                goals[idx] = result.goal
            }
            contributeAmount = ""
            showContribute = false
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        } catch {
            print("Failed to contribute: \(error)")
        }
    }
}
