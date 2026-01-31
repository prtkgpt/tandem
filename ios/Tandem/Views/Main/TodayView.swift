import SwiftUI

struct TodayView: View {
    @EnvironmentObject var appViewModel: AppViewModel

    @State private var topic: TableTopic?
    @State private var topicLoaded = false
    @State private var appreciationText = ""
    @State private var showTimeLogger = false
    @State private var isSendingAppreciation = false
    @State private var appreciationSent = false

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        let name = appViewModel.currentUser?.name ?? "there"
        if hour < 12 { return "Good morning, \(name)" }
        if hour < 17 { return "Good afternoon, \(name)" }
        return "Good evening, \(name)"
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Greeting
                    VStack(alignment: .leading, spacing: 4) {
                        Text(greeting)
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(Theme.textPrimary)
                        if let partner = appViewModel.partnerName {
                            Text("You & \(partner)")
                                .font(.subheadline)
                                .foregroundColor(Theme.textSecondary)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)

                    // Table Topic
                    TopicCardView(
                        topic: topic,
                        currentUserId: appViewModel.currentUser?.id ?? "",
                        partnerName: appViewModel.partnerName ?? "Partner",
                        onRespond: { text in
                            Task { await respondToTopic(text: text) }
                        }
                    )
                    .padding(.horizontal)

                    // Today I Noticed
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Today I Noticed...")
                            .font(.headline)
                            .foregroundColor(Theme.textPrimary)

                        HStack(spacing: 12) {
                            TextField(
                                "Something I appreciate about you...",
                                text: $appreciationText,
                                axis: .vertical
                            )
                            .textFieldStyle(.plain)
                            .padding(12)
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                            .lineLimit(1...3)

                            Button {
                                Task { await sendAppreciation() }
                            } label: {
                                if isSendingAppreciation {
                                    ProgressView()
                                        .tint(.white)
                                } else {
                                    Image(systemName: appreciationSent ? "checkmark" : "arrow.up.circle.fill")
                                        .font(.title2)
                                }
                            }
                            .frame(width: 44, height: 44)
                            .background(Theme.primary)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .disabled(appreciationText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isSendingAppreciation)
                        }

                        if appreciationSent {
                            Text("Sent with love!")
                                .font(.caption)
                                .foregroundColor(Theme.primary)
                                .transition(.opacity)
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(Theme.cardRadius)
                    .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
                    .padding(.horizontal)

                    // Log Our Time
                    Button {
                        showTimeLogger = true
                    } label: {
                        HStack {
                            Image(systemName: "clock.fill")
                            Text("Log Our Time Together")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Theme.secondary.opacity(0.15))
                        .foregroundColor(Theme.secondary)
                        .cornerRadius(Theme.buttonRadius)
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .background(Theme.background)
            .refreshable { await loadTopic() }
            .task { await loadTopic() }
            .sheet(isPresented: $showTimeLogger) {
                TimeLoggerSheet(
                    onSubmit: { activity, duration, date in
                        Task { await logTime(activity: activity, duration: duration, date: date) }
                    },
                    onDismiss: { showTimeLogger = false }
                )
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func loadTopic() async {
        do {
            let result = try await APIService.shared.getTodayTopic()
            topic = result.topic
            topicLoaded = true
        } catch {
            topicLoaded = true
        }
    }

    private func respondToTopic(text: String) async {
        do {
            let result = try await APIService.shared.respondToTopic(text: text)
            withAnimation { topic = result.topic }
        } catch {
            print("Failed to respond: \(error)")
        }
    }

    private func sendAppreciation() async {
        let message = appreciationText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !message.isEmpty else { return }
        isSendingAppreciation = true
        do {
            _ = try await APIService.shared.createAppreciation(message: String(message.prefix(200)))
            appreciationText = ""
            withAnimation { appreciationSent = true }
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            withAnimation { appreciationSent = false }
        } catch {
            print("Failed to send appreciation: \(error)")
        }
        isSendingAppreciation = false
    }

    private func logTime(activity: String, duration: Int, date: Date) async {
        do {
            let formatter = ISO8601DateFormatter()
            _ = try await APIService.shared.logTime(
                activityName: activity,
                durationMinutes: duration,
                date: formatter.string(from: date)
            )
            showTimeLogger = false
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        } catch {
            print("Failed to log time: \(error)")
        }
    }
}
