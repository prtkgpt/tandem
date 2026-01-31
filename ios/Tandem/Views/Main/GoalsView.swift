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
    @State private var newEmoji = "\u{1F4B0}"
    @State private var contributeAmount = ""

    private let emojiOptions = ["\u{1F4B0}", "\u{1F3D6}\u{FE0F}", "\u{1F3E0}", "\u{1F697}", "\u{1F48D}", "\u{1F393}", "\u{1F6EB}", "\u{1F381}", "\u{1F3CB}\u{FE0F}", "\u{1F4F1}"]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: TandemSpacing.lg) {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: TandemColors.goalColor))
                            .padding(.top, 60)
                    } else if goals.isEmpty {
                        emptyState
                    } else {
                        goalsHeader

                        ForEach(goals) { goal in
                            GoalCardView(goal: goal) {
                                selectedGoal = goal
                                showContribute = true
                            }
                            .padding(.horizontal, TandemSpacing.md)
                        }
                    }
                }
                .padding(.bottom, TandemSpacing.xl)
            }
            .background(TandemColors.background.ignoresSafeArea())
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showNewGoal = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 22))
                            .foregroundColor(TandemColors.goalColor)
                    }
                }
            }
            .refreshable { await loadGoals() }
            .task { await loadGoals() }
            .sheet(isPresented: $showNewGoal) { newGoalSheet }
            .sheet(isPresented: $showContribute) { contributeSheet }
        }
    }

    // MARK: - Header

    private var goalsHeader: some View {
        ZStack(alignment: .bottomLeading) {
            LinearGradient(
                colors: [
                    TandemColors.goalColor.opacity(0.12),
                    TandemColors.secondary.opacity(0.06),
                    TandemColors.background,
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .frame(height: 120)

            VStack(alignment: .leading, spacing: TandemSpacing.xs) {
                Text("Savings Goals")
                    .font(TandemFonts.largeTitle)
                    .foregroundColor(TandemColors.textPrimary)

                Text("\(goals.count) active goal\(goals.count == 1 ? "" : "s")")
                    .font(TandemFonts.body)
                    .foregroundColor(TandemColors.goalColor)
            }
            .padding(.horizontal, TandemSpacing.md)
            .padding(.bottom, TandemSpacing.md)
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: TandemSpacing.lg) {
            Spacer().frame(height: TandemSpacing.xxl)

            ZStack {
                Circle()
                    .fill(TandemColors.goalColor.opacity(0.12))
                    .frame(width: 100, height: 100)
                Image(systemName: "chart.bar.fill")
                    .font(.system(size: 44))
                    .foregroundColor(TandemColors.goalColor)
            }

            VStack(spacing: TandemSpacing.sm) {
                Text("Start Saving Together")
                    .font(TandemFonts.title)
                    .foregroundColor(TandemColors.textPrimary)

                Text("Create shared savings goals and track your progress as a couple.")
                    .font(TandemFonts.body)
                    .foregroundColor(TandemColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, TandemSpacing.lg)
            }

            Button {
                showNewGoal = true
            } label: {
                Text("Create First Goal")
                    .font(TandemFonts.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, TandemSpacing.md)
                    .background(
                        LinearGradient(
                            colors: [TandemColors.goalColor, TandemColors.secondary],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(TandemCornerRadius.button)
                    .shadow(
                        color: TandemColors.goalColor.opacity(0.3),
                        radius: 8, x: 0, y: 4
                    )
            }
            .padding(.horizontal, TandemSpacing.xl)
        }
    }

    // MARK: - New Goal Sheet

    private var newGoalSheet: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: TandemSpacing.lg) {
                    // Emoji picker
                    VStack(alignment: .leading, spacing: TandemSpacing.sm) {
                        Text("Choose an icon")
                            .font(TandemFonts.headline)
                            .foregroundColor(TandemColors.textPrimary)

                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: TandemSpacing.sm) {
                            ForEach(emojiOptions, id: \.self) { emoji in
                                Button {
                                    newEmoji = emoji
                                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                } label: {
                                    Text(emoji)
                                        .font(.system(size: 28))
                                        .frame(width: 52, height: 52)
                                        .background(
                                            RoundedRectangle(cornerRadius: TandemCornerRadius.small)
                                                .fill(newEmoji == emoji
                                                      ? TandemColors.goalColor.opacity(0.15)
                                                      : TandemColors.background)
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: TandemCornerRadius.small)
                                                .stroke(newEmoji == emoji ? TandemColors.goalColor : Color.clear, lineWidth: 2)
                                        )
                                }
                            }
                        }
                    }

                    // Goal name
                    VStack(alignment: .leading, spacing: TandemSpacing.xs) {
                        Text("Goal name")
                            .font(TandemFonts.captionBold)
                            .foregroundColor(TandemColors.textSecondary)
                        TextField("e.g., Vacation Fund", text: $newName)
                            .font(TandemFonts.body)
                            .padding(TandemSpacing.sm)
                            .background(
                                RoundedRectangle(cornerRadius: TandemCornerRadius.small)
                                    .fill(TandemColors.background)
                            )
                    }

                    // Target amount
                    VStack(alignment: .leading, spacing: TandemSpacing.xs) {
                        Text("Target amount")
                            .font(TandemFonts.captionBold)
                            .foregroundColor(TandemColors.textSecondary)
                        TextField("$0", text: $newTarget)
                            .font(TandemFonts.title)
                            .keyboardType(.decimalPad)
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
            .navigationTitle("New Goal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { showNewGoal = false }
                        .foregroundColor(TandemColors.textSecondary)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        Task { await createGoal() }
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(TandemColors.goalColor)
                    .disabled(newName.isEmpty || newTarget.isEmpty)
                }
            }
        }
        .presentationDetents([.medium])
    }

    // MARK: - Contribute Sheet

    private var contributeSheet: some View {
        NavigationStack {
            VStack(spacing: TandemSpacing.lg) {
                if let goal = selectedGoal {
                    Spacer().frame(height: TandemSpacing.md)

                    Text(goal.emoji)
                        .font(.system(size: 56))

                    Text(goal.name)
                        .font(TandemFonts.title)
                        .foregroundColor(TandemColors.textPrimary)

                    Text("$\(Int(goal.currentAmount)) / $\(Int(goal.targetAmount))")
                        .font(TandemFonts.callout)
                        .foregroundColor(TandemColors.textSecondary)

                    VStack(spacing: TandemSpacing.sm) {
                        Text("Amount to add")
                            .font(TandemFonts.captionBold)
                            .foregroundColor(TandemColors.textSecondary)

                        TextField("$0", text: $contributeAmount)
                            .keyboardType(.decimalPad)
                            .font(TandemFonts.largeTitle)
                            .multilineTextAlignment(.center)
                            .foregroundColor(TandemColors.goalColor)
                            .padding(TandemSpacing.md)
                            .background(
                                RoundedRectangle(cornerRadius: TandemCornerRadius.button)
                                    .fill(TandemColors.goalColor.opacity(0.08))
                            )
                            .padding(.horizontal, TandemSpacing.xl)
                    }

                    Button {
                        Task { await contribute() }
                    } label: {
                        Text("Add Contribution")
                            .font(TandemFonts.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, TandemSpacing.md)
                            .background(
                                LinearGradient(
                                    colors: [TandemColors.goalColor, TandemColors.secondary],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(TandemCornerRadius.button)
                            .shadow(
                                color: TandemColors.goalColor.opacity(0.3),
                                radius: 8, x: 0, y: 4
                            )
                    }
                    .padding(.horizontal, TandemSpacing.md)
                    .disabled(contributeAmount.isEmpty)
                    .opacity(contributeAmount.isEmpty ? 0.6 : 1.0)
                }
                Spacer()
            }
            .background(TandemColors.cardBackground.ignoresSafeArea())
            .navigationTitle("Contribute")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { showContribute = false }
                        .foregroundColor(TandemColors.textSecondary)
                }
            }
        }
        .presentationDetents([.medium])
    }

    // MARK: - API Calls

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
            newEmoji = "\u{1F4B0}"
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
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        } catch {
            print("Failed to contribute: \(error)")
        }
    }
}
