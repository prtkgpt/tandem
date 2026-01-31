import SwiftUI

struct TopicCardView: View {
    let topic: TableTopic?
    let currentUserId: String
    let partnerName: String
    let onRespond: (String) -> Void

    @State private var responseText: String = ""
    @State private var isSubmitting: Bool = false
    @State private var showPulse: Bool = false

    // MARK: - Computed State

    private var myResponse: TopicResponse? {
        topic?.responses.first(where: { $0.userId == currentUserId })
    }

    private var partnerResponse: TopicResponse? {
        topic?.responses.first(where: { $0.userId != currentUserId })
    }

    private enum TopicState {
        case noTopic
        case awaitingMyResponse
        case waitingForPartner
        case bothResponded
    }

    private var currentState: TopicState {
        guard let topic = topic else { return .noTopic }
        if topic.bothResponded { return .bothResponded }
        if myResponse != nil { return .waitingForPartner }
        return .awaitingMyResponse
    }

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: TandemSpacing.md) {
            switch currentState {
            case .noTopic:
                noTopicView
            case .awaitingMyResponse:
                awaitingResponseView
            case .waitingForPartner:
                waitingView
            case .bothResponded:
                revealedView
            }
        }
        .padding(TandemSpacing.lg)
        .background(TandemColors.cardBackground)
        .cornerRadius(TandemCornerRadius.card)
        .shadow(color: Color.black.opacity(0.06), radius: 10, x: 0, y: 4)
        .animation(.easeInOut(duration: 0.3), value: currentState == .bothResponded)
    }

    // MARK: - No Topic

    private var noTopicView: some View {
        VStack(spacing: TandemSpacing.md) {
            Image(systemName: "bubble.left.and.bubble.right")
                .font(.system(size: 40))
                .foregroundColor(TandemColors.textSecondary.opacity(0.4))

            Text("No topic for today")
                .font(TandemFonts.headline)
                .foregroundColor(TandemColors.textPrimary)

            Text("Check back at your scheduled time")
                .font(TandemFonts.caption)
                .foregroundColor(TandemColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, TandemSpacing.lg)
    }

    // MARK: - Awaiting My Response

    private var awaitingResponseView: some View {
        VStack(alignment: .leading, spacing: TandemSpacing.md) {
            categoryBadge

            Text(topic?.questionText ?? "")
                .font(TandemFonts.title)
                .foregroundColor(TandemColors.textPrimary)
                .fixedSize(horizontal: false, vertical: true)

            // Response input
            VStack(spacing: TandemSpacing.sm) {
                TextField("Share your thoughts...", text: $responseText, axis: .vertical)
                    .font(TandemFonts.body)
                    .lineLimit(3...6)
                    .padding(TandemSpacing.md)
                    .background(TandemColors.background)
                    .cornerRadius(TandemCornerRadius.small)

                Button(action: submitResponse) {
                    HStack {
                        if isSubmitting {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text("Share")
                                .font(TandemFonts.headline)
                        }
                    }
                    .tandemButton()
                }
                .disabled(responseText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isSubmitting)
                .opacity(responseText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.5 : 1.0)
            }
        }
    }

    // MARK: - Waiting for Partner

    private var waitingView: some View {
        VStack(alignment: .leading, spacing: TandemSpacing.md) {
            categoryBadge

            Text(topic?.questionText ?? "")
                .font(TandemFonts.title)
                .foregroundColor(TandemColors.textPrimary)
                .fixedSize(horizontal: false, vertical: true)

            // My response shown faded
            if let myResponse = myResponse {
                VStack(alignment: .leading, spacing: TandemSpacing.xs) {
                    Text("Your answer")
                        .font(TandemFonts.caption)
                        .foregroundColor(TandemColors.textSecondary)
                    Text(myResponse.text)
                        .font(TandemFonts.body)
                        .foregroundColor(TandemColors.textPrimary.opacity(0.7))
                }
                .padding(TandemSpacing.md)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(TandemColors.background)
                .cornerRadius(TandemCornerRadius.small)
            }

            // Waiting indicator
            HStack(spacing: TandemSpacing.sm) {
                Circle()
                    .fill(TandemColors.secondary)
                    .frame(width: 8, height: 8)
                    .scaleEffect(showPulse ? 1.3 : 0.8)
                    .animation(
                        .easeInOut(duration: 0.8).repeatForever(autoreverses: true),
                        value: showPulse
                    )

                Text("Waiting for \(partnerName)...")
                    .font(TandemFonts.body)
                    .foregroundColor(TandemColors.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, TandemSpacing.sm)
            .onAppear { showPulse = true }
        }
    }

    // MARK: - Both Responded

    private var revealedView: some View {
        VStack(alignment: .leading, spacing: TandemSpacing.md) {
            categoryBadge

            Text(topic?.questionText ?? "")
                .font(TandemFonts.title)
                .foregroundColor(TandemColors.textPrimary)
                .fixedSize(horizontal: false, vertical: true)

            // Side-by-side answers
            HStack(alignment: .top, spacing: TandemSpacing.md) {
                // My answer
                responseColumn(
                    name: "You",
                    text: myResponse?.text ?? "",
                    color: TandemColors.primary.opacity(0.08)
                )

                // Partner answer
                responseColumn(
                    name: partnerName,
                    text: partnerResponse?.text ?? "",
                    color: TandemColors.secondary.opacity(0.08)
                )
            }
            .transition(.opacity.combined(with: .scale(scale: 0.95)))
        }
    }

    // MARK: - Helpers

    private var categoryBadge: some View {
        Group {
            if let category = topic?.category, !category.isEmpty {
                Text(category.uppercased())
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundColor(TandemColors.secondary)
                    .padding(.horizontal, TandemSpacing.sm)
                    .padding(.vertical, TandemSpacing.xs)
                    .background(TandemColors.secondary.opacity(0.12))
                    .cornerRadius(TandemCornerRadius.small)
            }
        }
    }

    private func responseColumn(name: String, text: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: TandemSpacing.xs) {
            Text(name)
                .font(TandemFonts.caption)
                .fontWeight(.semibold)
                .foregroundColor(TandemColors.textSecondary)

            Text(text)
                .font(TandemFonts.body)
                .foregroundColor(TandemColors.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(TandemSpacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(color)
        .cornerRadius(TandemCornerRadius.small)
    }

    private func submitResponse() {
        let trimmed = responseText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        // Haptic feedback
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()

        isSubmitting = true
        onRespond(trimmed)

        // Reset after a brief delay to show loading state
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isSubmitting = false
            responseText = ""
        }
    }
}

// MARK: - Preview

#Preview("No Topic") {
    TopicCardView(
        topic: nil,
        currentUserId: "user1",
        partnerName: "Alex",
        onRespond: { _ in }
    )
    .padding()
}

#Preview("Awaiting Response") {
    TopicCardView(
        topic: TableTopic(
            id: "1",
            questionText: "What's one thing your partner did this week that made you smile?",
            category: "Gratitude",
            askedDate: "2026-01-31",
            responses: [],
            bothResponded: false
        ),
        currentUserId: "user1",
        partnerName: "Alex",
        onRespond: { _ in }
    )
    .padding()
}

#Preview("Both Responded") {
    TopicCardView(
        topic: TableTopic(
            id: "1",
            questionText: "What's your ideal weekend together?",
            category: "Dreams",
            askedDate: "2026-01-31",
            responses: [
                TopicResponse(id: "r1", userId: "user1", userName: "Me", text: "Lazy morning, then hiking and cooking dinner together.", createdAt: "2026-01-31T10:00:00Z"),
                TopicResponse(id: "r2", userId: "user2", userName: "Alex", text: "Sleeping in, brunch out, then a movie marathon at home.", createdAt: "2026-01-31T11:00:00Z")
            ],
            bothResponded: true
        ),
        currentUserId: "user1",
        partnerName: "Alex",
        onRespond: { _ in }
    )
    .padding()
}
