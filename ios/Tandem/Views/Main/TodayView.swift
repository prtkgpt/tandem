import SwiftUI

struct TodayView: View {
    @EnvironmentObject var appViewModel: AppViewModel

    // MARK: - Topic State

    @State private var topic: TableTopic?
    @State private var responseText = ""
    @State private var isLoadingTopic = true
    @State private var isSubmittingResponse = false

    // MARK: - Appreciation State

    @State private var appreciationText = ""
    @State private var isSubmittingAppreciation = false
    @State private var showAppreciationSuccess = false

    // MARK: - Log Time State

    @State private var showLogTimeSheet = false

    // MARK: - Nudge State

    @State private var nudgeSent = false
    @State private var isSendingNudge = false
    @State private var receivedNudge: NudgeItem?

    // MARK: - Error

    @State private var errorMessage: String?

    // MARK: - Computed Properties

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        let firstName = appViewModel.currentUser?.name
            .components(separatedBy: " ").first ?? "there"
        if hour < 12 {
            return "Good morning, \(firstName)"
        } else if hour < 17 {
            return "Good afternoon, \(firstName)"
        } else {
            return "Good evening, \(firstName)"
        }
    }

    private var currentUserId: String {
        appViewModel.currentUser?.id ?? ""
    }

    private var userHasResponded: Bool {
        topic?.responses.contains { $0.userId == currentUserId } ?? false
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: TandemSpacing.lg) {
                    greetingHeader
                    nudgeSection
                    tableTopicCard
                    appreciationSection
                    logTimeSection
                }
                .padding(.bottom, TandemSpacing.xl)
            }
            .background(TandemColors.background.ignoresSafeArea())
            .refreshable {
                await loadTopic()
                await checkNudges()
            }
            .task {
                await loadTopic()
                await checkNudges()
            }
            .sheet(isPresented: $showLogTimeSheet) {
                LogTimeSheet()
                    .environmentObject(appViewModel)
            }
            .alert("Something went wrong", isPresented: Binding(
                get: { errorMessage != nil },
                set: { if !$0 { errorMessage = nil } }
            )) {
                Button("OK", role: .cancel) { errorMessage = nil }
            } message: {
                Text(errorMessage ?? "")
            }
        }
    }

    // MARK: - Greeting Header (Vibrant Gradient)

    private var greetingHeader: some View {
        ZStack(alignment: .bottomLeading) {
            // Gradient background
            LinearGradient(
                colors: [
                    TandemColors.primary.opacity(0.15),
                    TandemColors.accent.opacity(0.08),
                    TandemColors.background,
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .frame(height: 160)

            VStack(alignment: .leading, spacing: TandemSpacing.xs) {
                // Date
                Text(Date(), format: .dateTime.weekday(.wide).month(.wide).day())
                    .font(TandemFonts.caption)
                    .fontWeight(.medium)
                    .foregroundColor(TandemColors.primary)

                Text(greeting)
                    .font(TandemFonts.largeTitle)
                    .foregroundColor(TandemColors.textPrimary)

                if appViewModel.isPaired {
                    Text("How are you and \(appViewModel.partnerName ?? "your partner") today?")
                        .font(TandemFonts.body)
                        .foregroundColor(TandemColors.textSecondary)
                }
            }
            .padding(.horizontal, TandemSpacing.md)
            .padding(.bottom, TandemSpacing.md)
        }
    }

    // MARK: - Nudge Section

    private var nudgeSection: some View {
        VStack(spacing: TandemSpacing.sm) {
            // Received nudge banner
            if let nudge = receivedNudge {
                HStack(spacing: TandemSpacing.sm) {
                    Text(nudge.emoji)
                        .font(.system(size: 24))
                    VStack(alignment: .leading, spacing: 2) {
                        Text("\(nudge.fromUserName) \(nudge.message)")
                            .font(TandemFonts.headline)
                            .foregroundColor(TandemColors.textPrimary)
                        Text("right now")
                            .font(TandemFonts.caption)
                            .foregroundColor(TandemColors.nudgeColor)
                    }
                    Spacer()
                    Button {
                        withAnimation(.spring()) { receivedNudge = nil }
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(TandemColors.textSecondary.opacity(0.4))
                    }
                }
                .padding(TandemSpacing.md)
                .background(
                    RoundedRectangle(cornerRadius: TandemCornerRadius.card)
                        .fill(TandemColors.nudgeColor.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: TandemCornerRadius.card)
                                .stroke(TandemColors.nudgeColor.opacity(0.2), lineWidth: 1)
                        )
                )
                .transition(.move(edge: .top).combined(with: .opacity))
            }

            // Send nudge button
            if appViewModel.isPaired {
                Button {
                    Task { await sendNudge() }
                } label: {
                    HStack(spacing: TandemSpacing.sm) {
                        Image(systemName: nudgeSent ? "checkmark.heart.fill" : "heart.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(nudgeSent ? TandemColors.secondary : TandemColors.nudgeColor)
                        Text(nudgeSent ? "Sent!" : "Thinking of \(appViewModel.partnerName ?? "you")")
                            .font(TandemFonts.callout)
                            .foregroundColor(nudgeSent ? TandemColors.secondary : TandemColors.nudgeColor)
                        Spacer()
                        if isSendingNudge {
                            ProgressView()
                                .scaleEffect(0.7)
                        }
                    }
                    .padding(.horizontal, TandemSpacing.md)
                    .padding(.vertical, TandemSpacing.sm)
                    .background(
                        RoundedRectangle(cornerRadius: TandemCornerRadius.button)
                            .fill(nudgeSent ? TandemColors.secondary.opacity(0.08) : TandemColors.nudgeColor.opacity(0.08))
                    )
                }
                .disabled(nudgeSent || isSendingNudge)
            }
        }
        .padding(.horizontal, TandemSpacing.md)
    }

    // MARK: - Table Topic Card

    private var tableTopicCard: some View {
        VStack(alignment: .leading, spacing: TandemSpacing.md) {
            // Header
            HStack {
                Image(systemName: "bubble.left.and.bubble.right.fill")
                    .foregroundColor(TandemColors.primary)
                Text("Table Topic")
                    .font(TandemFonts.headline)
                    .foregroundColor(TandemColors.textPrimary)
                Spacer()
                Text("Daily Question")
                    .font(TandemFonts.caption)
                    .foregroundColor(TandemColors.textSecondary)
            }

            if isLoadingTopic {
                topicLoadingState
            } else if let currentTopic = topic {
                topicContent(currentTopic)
            } else {
                topicEmptyState
            }
        }
        .tandemCard()
    }

    private var topicLoadingState: some View {
        HStack {
            Spacer()
            VStack(spacing: TandemSpacing.sm) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: TandemColors.primary))
                Text("Loading today's question...")
                    .font(TandemFonts.caption)
                    .foregroundColor(TandemColors.textSecondary)
            }
            Spacer()
        }
        .padding(.vertical, TandemSpacing.lg)
    }

    @ViewBuilder
    private func topicContent(_ currentTopic: TableTopic) -> some View {
        // Question text
        Text(currentTopic.questionText)
            .font(TandemFonts.title)
            .foregroundColor(TandemColors.textPrimary)
            .fixedSize(horizontal: false, vertical: true)

        // Category badge
        Text(currentTopic.category.uppercased())
            .font(TandemFonts.caption)
            .fontWeight(.semibold)
            .foregroundColor(TandemColors.secondary)
            .padding(.horizontal, TandemSpacing.sm)
            .padding(.vertical, TandemSpacing.xs)
            .background(
                Capsule().fill(TandemColors.secondary.opacity(0.12))
            )

        Divider()

        // Conditional state
        if currentTopic.bothResponded {
            bothRespondedState(currentTopic)
        } else if userHasResponded {
            waitingForPartnerState
        } else {
            responseInputState(topicId: currentTopic.id)
        }
    }

    private var topicEmptyState: some View {
        VStack(spacing: TandemSpacing.sm) {
            Image(systemName: "bubble.left.and.bubble.right")
                .font(.system(size: 40))
                .foregroundColor(TandemColors.textSecondary.opacity(0.4))
            Text("No topic for today yet")
                .font(TandemFonts.body)
                .foregroundColor(TandemColors.textSecondary)
            Text("Check back soon -- a new question drops daily!")
                .font(TandemFonts.caption)
                .foregroundColor(TandemColors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, TandemSpacing.lg)
    }

    // MARK: - Topic Response States

    private func bothRespondedState(_ currentTopic: TableTopic) -> some View {
        VStack(alignment: .leading, spacing: TandemSpacing.md) {
            ForEach(currentTopic.responses) { response in
                let isMine = response.userId == currentUserId
                VStack(alignment: .leading, spacing: TandemSpacing.xs) {
                    Text(isMine ? "You" : response.userName)
                        .font(TandemFonts.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(isMine ? TandemColors.primary : TandemColors.secondary)

                    Text(response.text)
                        .font(TandemFonts.body)
                        .foregroundColor(TandemColors.textPrimary)
                }
                .padding(TandemSpacing.sm)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: TandemCornerRadius.small)
                        .fill(isMine
                              ? TandemColors.primary.opacity(0.08)
                              : TandemColors.secondary.opacity(0.08))
                )
            }

            HStack {
                Spacer()
                Label("Both answered!", systemImage: "checkmark.circle.fill")
                    .font(TandemFonts.caption)
                    .foregroundColor(TandemColors.secondary)
                Spacer()
            }
        }
    }

    private var waitingForPartnerState: some View {
        VStack(spacing: TandemSpacing.sm) {
            // Show the user's own response
            if let myResponse = topic?.responses.first(where: { $0.userId == currentUserId }) {
                VStack(alignment: .leading, spacing: TandemSpacing.xs) {
                    Text("Your answer")
                        .font(TandemFonts.caption)
                        .foregroundColor(TandemColors.textSecondary)
                    Text(myResponse.text)
                        .font(TandemFonts.body)
                        .foregroundColor(TandemColors.textPrimary)
                }
                .padding(TandemSpacing.sm)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: TandemCornerRadius.small)
                        .fill(TandemColors.primary.opacity(0.08))
                )
            }

            HStack(spacing: TandemSpacing.sm) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: TandemColors.accent))
                    .scaleEffect(0.8)
                Text("Waiting for \(appViewModel.partnerName ?? "your partner")...")
                    .font(TandemFonts.body)
                    .foregroundColor(TandemColors.textSecondary)
            }
            .padding(.top, TandemSpacing.xs)
        }
    }

    private func responseInputState(topicId: String) -> some View {
        VStack(spacing: TandemSpacing.sm) {
            TextField("Share your thoughts...", text: $responseText, axis: .vertical)
                .font(TandemFonts.body)
                .lineLimit(3...6)
                .textFieldStyle(.plain)
                .padding(TandemSpacing.sm)
                .background(
                    RoundedRectangle(cornerRadius: TandemCornerRadius.small)
                        .fill(TandemColors.background)
                )

            Button {
                Task { await submitResponse(topicId: topicId) }
            } label: {
                HStack(spacing: TandemSpacing.sm) {
                    if isSubmittingResponse {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                    }
                    Text(isSubmittingResponse ? "Sending..." : "Share Answer")
                }
                .tandemButton()
            }
            .disabled(
                responseText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                || isSubmittingResponse
            )
            .opacity(
                responseText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.6 : 1.0
            )
        }
    }

    // MARK: - Appreciation Section

    private var appreciationSection: some View {
        VStack(alignment: .leading, spacing: TandemSpacing.sm) {
            HStack {
                Image(systemName: "heart.text.square.fill")
                    .foregroundColor(TandemColors.accent)
                Text("Today I Noticed...")
                    .font(TandemFonts.headline)
                    .foregroundColor(TandemColors.textPrimary)
            }

            Text("Send a quick appreciation to \(appViewModel.partnerName ?? "your partner")")
                .font(TandemFonts.caption)
                .foregroundColor(TandemColors.textSecondary)

            HStack(spacing: TandemSpacing.sm) {
                TextField("Something you appreciate...", text: $appreciationText, axis: .vertical)
                    .font(TandemFonts.body)
                    .lineLimit(1...3)
                    .textFieldStyle(.plain)

                Button {
                    Task { await submitAppreciation() }
                } label: {
                    Group {
                        if isSubmittingAppreciation {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.8)
                        } else {
                            Image(systemName: showAppreciationSuccess
                                  ? "checkmark" : "paperplane.fill")
                        }
                    }
                    .frame(width: 44, height: 44)
                    .background(
                        appreciationText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                            ? TandemColors.textSecondary.opacity(0.3)
                            : TandemColors.primary
                    )
                    .foregroundColor(.white)
                    .clipShape(Circle())
                }
                .disabled(
                    appreciationText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                    || isSubmittingAppreciation
                )
            }
            .padding(TandemSpacing.sm)
            .background(
                RoundedRectangle(cornerRadius: TandemCornerRadius.small)
                    .fill(TandemColors.background)
            )

            HStack {
                Text("\(appreciationText.count)/200")
                    .font(TandemFonts.caption)
                    .foregroundColor(
                        appreciationText.count > 180
                            ? TandemColors.primary : TandemColors.textSecondary
                    )

                Spacer()

                if showAppreciationSuccess {
                    HStack(spacing: TandemSpacing.xs) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(TandemColors.secondary)
                        Text("Sent with love!")
                            .font(TandemFonts.caption)
                            .foregroundColor(TandemColors.secondary)
                    }
                    .transition(.opacity.combined(with: .scale))
                }
            }
        }
        .tandemCard()
        .onChange(of: appreciationText) { newValue in
            if newValue.count > 200 {
                appreciationText = String(newValue.prefix(200))
            }
        }
    }

    // MARK: - Log Time Section

    private var logTimeSection: some View {
        Button {
            showLogTimeSheet = true
        } label: {
            HStack(spacing: TandemSpacing.md) {
                ZStack {
                    Circle()
                        .fill(TandemColors.secondary.opacity(0.15))
                        .frame(width: 48, height: 48)
                    Image(systemName: "clock.fill")
                        .font(.system(size: 22))
                        .foregroundColor(TandemColors.secondary)
                }

                VStack(alignment: .leading, spacing: TandemSpacing.xs) {
                    Text("Log Our Time")
                        .font(TandemFonts.headline)
                        .foregroundColor(TandemColors.textPrimary)
                    Text("How was your time together?")
                        .font(TandemFonts.caption)
                        .foregroundColor(TandemColors.textSecondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(TandemFonts.body)
                    .foregroundColor(TandemColors.textSecondary.opacity(0.6))
            }
        }
        .tandemCard()
    }

    // MARK: - API Calls

    private func loadTopic() async {
        isLoadingTopic = true
        do {
            let wrapper = try await APIService.shared.getTodayTopic()
            withAnimation {
                topic = wrapper.topic
                isLoadingTopic = false
            }
        } catch {
            withAnimation { isLoadingTopic = false }
            errorMessage = error.localizedDescription
        }
    }

    private func submitResponse(topicId: String) async {
        let text = responseText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }

        isSubmittingResponse = true
        let generator = UIImpactFeedbackGenerator(style: .medium)

        do {
            let wrapper = try await APIService.shared.respondToTopic(text: text)
            generator.impactOccurred()
            withAnimation {
                topic = wrapper.topic
                responseText = ""
                isSubmittingResponse = false
            }
        } catch {
            isSubmittingResponse = false
            errorMessage = error.localizedDescription
        }
    }

    private func sendNudge() async {
        isSendingNudge = true
        do {
            _ = try await APIService.shared.sendNudge()
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            withAnimation(.spring()) {
                nudgeSent = true
                isSendingNudge = false
            }
            try? await Task.sleep(nanoseconds: 5_000_000_000)
            withAnimation { nudgeSent = false }
        } catch {
            isSendingNudge = false
        }
    }

    private func checkNudges() async {
        guard appViewModel.isPaired else { return }
        do {
            let wrapper = try await APIService.shared.getUnseenNudges()
            if let latest = wrapper.nudges.first {
                withAnimation(.spring()) {
                    receivedNudge = latest
                }
                // Auto-dismiss after 8 seconds
                try? await Task.sleep(nanoseconds: 8_000_000_000)
                withAnimation(.spring()) {
                    receivedNudge = nil
                }
            }
        } catch {
            // Silently fail — not critical
        }
    }

    private func submitAppreciation() async {
        let text = appreciationText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty, text.count <= 200 else { return }

        isSubmittingAppreciation = true
        let generator = UIImpactFeedbackGenerator(style: .light)

        do {
            _ = try await APIService.shared.createAppreciation(message: text)
            generator.impactOccurred()
            withAnimation {
                appreciationText = ""
                isSubmittingAppreciation = false
                showAppreciationSuccess = true
            }
            try? await Task.sleep(nanoseconds: 2_500_000_000)
            withAnimation { showAppreciationSuccess = false }
        } catch {
            isSubmittingAppreciation = false
            errorMessage = error.localizedDescription
        }
    }
}

// MARK: - Log Time Sheet

struct LogTimeSheet: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var selectedActivity = ""
    @State private var customActivity = ""
    @State private var durationMinutes: Double = 60
    @State private var isSubmitting = false
    @State private var errorMessage: String?

    private let quickPicks: [(name: String, icon: String)] = [
        ("Dinner", "fork.knife"),
        ("Walk", "figure.walk"),
        ("Movie Night", "tv"),
        ("Cooking", "frying.pan"),
        ("Talk", "bubble.left.and.bubble.right"),
    ]

    private var activityName: String {
        if !selectedActivity.isEmpty { return selectedActivity }
        return customActivity.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var durationLabel: String {
        let hours = Int(durationMinutes) / 60
        let mins = Int(durationMinutes) % 60
        if hours > 0 && mins > 0 { return "\(hours)h \(mins)m" }
        if hours > 0 { return "\(hours)h" }
        return "\(mins)m"
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: TandemSpacing.lg) {
                    // MARK: Activity Selection
                    VStack(alignment: .leading, spacing: TandemSpacing.sm) {
                        Text("What did you do together?")
                            .font(TandemFonts.headline)
                            .foregroundColor(TandemColors.textPrimary)

                        LazyVGrid(
                            columns: [GridItem(.flexible()), GridItem(.flexible())],
                            spacing: TandemSpacing.sm
                        ) {
                            ForEach(quickPicks, id: \.name) { pick in
                                Button {
                                    withAnimation(.spring(response: 0.3)) {
                                        selectedActivity = pick.name
                                        customActivity = ""
                                    }
                                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                } label: {
                                    HStack(spacing: TandemSpacing.sm) {
                                        Image(systemName: pick.icon)
                                        Text(pick.name)
                                    }
                                    .font(TandemFonts.body)
                                    .foregroundColor(
                                        selectedActivity == pick.name
                                            ? .white : TandemColors.textPrimary
                                    )
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, TandemSpacing.sm)
                                    .padding(.horizontal, TandemSpacing.md)
                                    .background(
                                        RoundedRectangle(cornerRadius: TandemCornerRadius.button)
                                            .fill(
                                                selectedActivity == pick.name
                                                    ? TandemColors.primary
                                                    : TandemColors.cardBackground
                                            )
                                    )
                                    .shadow(
                                        color: Color.black.opacity(0.04),
                                        radius: 4, x: 0, y: 1
                                    )
                                }
                            }
                        }

                        TextField("Or type something custom...", text: $customActivity)
                            .font(TandemFonts.body)
                            .padding(TandemSpacing.sm)
                            .background(
                                RoundedRectangle(cornerRadius: TandemCornerRadius.small)
                                    .fill(TandemColors.cardBackground)
                            )
                            .onChange(of: customActivity) { newValue in
                                if !newValue.isEmpty { selectedActivity = "" }
                            }
                    }

                    // MARK: Duration Slider
                    VStack(alignment: .leading, spacing: TandemSpacing.sm) {
                        HStack {
                            Text("How long?")
                                .font(TandemFonts.headline)
                                .foregroundColor(TandemColors.textPrimary)
                            Spacer()
                            Text(durationLabel)
                                .font(TandemFonts.title)
                                .foregroundColor(TandemColors.primary)
                        }

                        Slider(value: $durationMinutes, in: 15...240, step: 15)
                            .tint(TandemColors.primary)

                        HStack {
                            Text("15 min")
                                .font(TandemFonts.caption)
                                .foregroundColor(TandemColors.textSecondary)
                            Spacer()
                            Text("4 hours")
                                .font(TandemFonts.caption)
                                .foregroundColor(TandemColors.textSecondary)
                        }
                    }

                    // MARK: Submit Button
                    Button {
                        Task { await submitLog() }
                    } label: {
                        HStack(spacing: TandemSpacing.sm) {
                            if isSubmitting {
                                ProgressView()
                                    .progressViewStyle(
                                        CircularProgressViewStyle(tint: .white)
                                    )
                                    .scaleEffect(0.8)
                            }
                            Text(isSubmitting ? "Logging..." : "Log Time Together")
                        }
                        .tandemButton()
                    }
                    .disabled(activityName.isEmpty || isSubmitting)
                    .opacity(activityName.isEmpty ? 0.6 : 1.0)
                }
                .padding(TandemSpacing.md)
            }
            .background(TandemColors.background.ignoresSafeArea())
            .navigationTitle("Log Our Time")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(TandemColors.primary)
                }
            }
            .alert("Something went wrong", isPresented: Binding(
                get: { errorMessage != nil },
                set: { if !$0 { errorMessage = nil } }
            )) {
                Button("OK", role: .cancel) { errorMessage = nil }
            } message: {
                Text(errorMessage ?? "")
            }
        }
    }

    private func submitLog() async {
        guard !activityName.isEmpty else { return }
        isSubmitting = true
        let generator = UIImpactFeedbackGenerator(style: .medium)

        do {
            _ = try await APIService.shared.logTime(
                activityName: activityName,
                durationMinutes: Int(durationMinutes)
            )
            generator.impactOccurred()
            dismiss()
        } catch {
            isSubmitting = false
            errorMessage = error.localizedDescription
        }
    }
}

#Preview {
    TodayView()
        .environmentObject(AppViewModel())
}
