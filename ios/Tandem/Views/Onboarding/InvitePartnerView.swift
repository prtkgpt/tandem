import SwiftUI

struct InvitePartnerView: View {
    @EnvironmentObject var appViewModel: AppViewModel

    @State private var inviteCode: String?
    @State private var partnerCode = ""
    @State private var isLoadingCode = false
    @State private var isJoining = false
    @State private var codeCopied = false
    @State private var errorMessage: String?
    @State private var showError = false
    @State private var headerOpacity: Double = 0
    @State private var cardsOffset: CGFloat = 40
    @State private var cardsOpacity: Double = 0

    @FocusState private var isCodeFieldFocused: Bool

    var body: some View {
        ScrollView {
            VStack(spacing: TandemSpacing.lg) {
                // MARK: - Header
                headerSection
                    .padding(.top, TandemSpacing.xl + TandemSpacing.md)
                    .opacity(headerOpacity)

                // MARK: - Share Your Code Section
                shareCodeCard
                    .padding(.horizontal, TandemSpacing.xl)

                // MARK: - Divider
                orDivider
                    .padding(.horizontal, TandemSpacing.xl)

                // MARK: - Enter Partner Code Section
                enterCodeCard
                    .padding(.horizontal, TandemSpacing.xl)

                // MARK: - Error Message
                if showError, let errorMessage = errorMessage {
                    errorBanner(message: errorMessage)
                        .padding(.horizontal, TandemSpacing.xl)
                        .transition(.asymmetric(
                            insertion: .move(edge: .top).combined(with: .opacity),
                            removal: .opacity
                        ))
                }

                // MARK: - Logout Option
                logoutButton
                    .padding(.top, TandemSpacing.md)

                Spacer(minLength: TandemSpacing.xl)
            }
            .offset(y: cardsOffset)
            .opacity(cardsOpacity)
        }
        .background(TandemColors.background.ignoresSafeArea())
        .scrollDismissesKeyboard(.interactively)
        .onTapGesture {
            isCodeFieldFocused = false
        }
        .onAppear {
            animateEntrance()
            generateInviteCode()
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(spacing: TandemSpacing.sm) {
            ZStack {
                Circle()
                    .fill(TandemColors.secondary.opacity(0.15))
                    .frame(width: 100, height: 100)

                Image(systemName: "person.2.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(
                        LinearGradient(
                            gradient: Gradient(colors: [TandemColors.secondary, TandemColors.primary]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            .padding(.bottom, TandemSpacing.sm)

            Text("Connect with Your Partner")
                .font(TandemFonts.title)
                .foregroundColor(TandemColors.textPrimary)

            Text("Share your invite code or enter theirs to get started together")
                .font(TandemFonts.body)
                .foregroundColor(TandemColors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, TandemSpacing.xl)
        }
    }

    // MARK: - Share Code Card

    private var shareCodeCard: some View {
        VStack(spacing: TandemSpacing.md) {
            HStack {
                Image(systemName: "square.and.arrow.up")
                    .foregroundColor(TandemColors.secondary)
                Text("Share Your Code")
                    .font(TandemFonts.headline)
                    .foregroundColor(TandemColors.textPrimary)
                Spacer()
            }

            if isLoadingCode {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: TandemColors.secondary))
                    .frame(height: 60)
            } else if let code = inviteCode {
                // Invite code display
                HStack(spacing: TandemSpacing.xs) {
                    ForEach(Array(code.enumerated()), id: \.offset) { _, character in
                        Text(String(character))
                            .font(.system(size: 28, weight: .bold, design: .monospaced))
                            .foregroundColor(TandemColors.textPrimary)
                            .frame(width: 42, height: 52)
                            .background(TandemColors.background)
                            .cornerRadius(TandemCornerRadius.small)
                    }
                }
                .padding(.vertical, TandemSpacing.sm)

                // Copy button
                Button {
                    copyCode()
                } label: {
                    HStack(spacing: TandemSpacing.sm) {
                        Image(systemName: codeCopied ? "checkmark.circle.fill" : "doc.on.doc")
                            .font(.system(size: 16))
                        Text(codeCopied ? "Copied!" : "Copy Code")
                            .font(TandemFonts.headline)
                    }
                    .foregroundColor(codeCopied ? TandemColors.secondary : TandemColors.primary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, TandemSpacing.sm + 2)
                    .background(
                        (codeCopied ? TandemColors.secondary : TandemColors.primary)
                            .opacity(0.1)
                    )
                    .cornerRadius(TandemCornerRadius.button)
                }
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: codeCopied)
            } else {
                // Error state with retry
                VStack(spacing: TandemSpacing.sm) {
                    Text("Could not generate code")
                        .font(TandemFonts.body)
                        .foregroundColor(TandemColors.textSecondary)

                    Button("Try Again") {
                        generateInviteCode()
                    }
                    .font(TandemFonts.headline)
                    .foregroundColor(TandemColors.primary)
                }
                .frame(height: 60)
            }
        }
        .tandemCard()
    }

    // MARK: - Or Divider

    private var orDivider: some View {
        HStack(spacing: TandemSpacing.md) {
            Rectangle()
                .fill(TandemColors.textSecondary.opacity(0.2))
                .frame(height: 1)

            Text("OR")
                .font(TandemFonts.caption)
                .foregroundColor(TandemColors.textSecondary)

            Rectangle()
                .fill(TandemColors.textSecondary.opacity(0.2))
                .frame(height: 1)
        }
    }

    // MARK: - Enter Code Card

    private var enterCodeCard: some View {
        VStack(spacing: TandemSpacing.md) {
            HStack {
                Image(systemName: "keyboard")
                    .foregroundColor(TandemColors.accent)
                Text("Enter Partner's Code")
                    .font(TandemFonts.headline)
                    .foregroundColor(TandemColors.textPrimary)
                Spacer()
            }

            // Code text field
            HStack(spacing: TandemSpacing.sm) {
                TextField("Enter 6-character code", text: $partnerCode)
                    .font(.system(size: 20, weight: .semibold, design: .monospaced))
                    .foregroundColor(TandemColors.textPrimary)
                    .textInputAutocapitalization(.characters)
                    .autocorrectionDisabled()
                    .multilineTextAlignment(.center)
                    .focused($isCodeFieldFocused)
                    .onChange(of: partnerCode) { _, newValue in
                        // Limit to 6 characters, uppercase
                        let filtered = String(newValue.uppercased().prefix(6))
                        if filtered != newValue {
                            partnerCode = filtered
                        }
                    }
                    .padding(TandemSpacing.md)
                    .background(TandemColors.background)
                    .cornerRadius(TandemCornerRadius.button)
                    .overlay(
                        RoundedRectangle(cornerRadius: TandemCornerRadius.button)
                            .stroke(
                                isCodeFieldFocused
                                    ? TandemColors.accent.opacity(0.5)
                                    : Color.clear,
                                lineWidth: 1.5
                            )
                    )
            }

            // Join button
            Button(action: joinPartner) {
                HStack(spacing: TandemSpacing.sm) {
                    if isJoining {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.9)
                    } else {
                        Image(systemName: "link")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Connect")
                    }
                }
                .tandemButton()
            }
            .disabled(partnerCode.count != 6 || isJoining)
            .opacity(partnerCode.count == 6 ? 1.0 : 0.6)
            .animation(.easeInOut(duration: 0.2), value: partnerCode.count)
            .animation(.easeInOut(duration: 0.2), value: isJoining)
        }
        .tandemCard()
    }

    // MARK: - Error Banner

    private func errorBanner(message: String) -> some View {
        HStack(spacing: TandemSpacing.sm) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(TandemColors.primary)

            Text(message)
                .font(TandemFonts.caption)
                .foregroundColor(TandemColors.primary)
                .multilineTextAlignment(.leading)

            Spacer()

            Button {
                withAnimation { clearError() }
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(TandemColors.primary.opacity(0.6))
            }
        }
        .padding(TandemSpacing.sm + 4)
        .background(TandemColors.primary.opacity(0.08))
        .cornerRadius(TandemCornerRadius.small)
    }

    // MARK: - Logout Button

    private var logoutButton: some View {
        Button {
            appViewModel.logout()
        } label: {
            Text("Sign Out")
                .font(TandemFonts.body)
                .foregroundColor(TandemColors.textSecondary)
        }
    }

    // MARK: - Entrance Animation

    private func animateEntrance() {
        withAnimation(.easeOut(duration: 0.4).delay(0.1)) {
            headerOpacity = 1.0
        }
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.2)) {
            cardsOffset = 0
            cardsOpacity = 1.0
        }
    }

    // MARK: - Actions

    private func generateInviteCode() {
        isLoadingCode = true
        clearError()

        Task {
            do {
                let response = try await APIService.shared.createInvite()
                await MainActor.run {
                    inviteCode = response.code
                    isLoadingCode = false
                }
            } catch {
                await MainActor.run {
                    inviteCode = nil
                    isLoadingCode = false
                    errorMessage = "Failed to generate invite code. Please try again."
                    withAnimation { showError = true }
                }
            }
        }
    }

    private func copyCode() {
        guard let code = inviteCode else { return }
        UIPasteboard.general.string = code
        codeCopied = true

        // Reset after 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation { codeCopied = false }
        }
    }

    private func joinPartner() {
        guard partnerCode.count == 6, !isJoining else { return }
        isCodeFieldFocused = false
        isJoining = true
        clearError()

        Task {
            do {
                let response = try await APIService.shared.joinPartner(code: partnerCode)
                await appViewModel.onPaired(
                    coupleId: response.coupleId,
                    partnerName: response.partnerName
                )
            } catch {
                await MainActor.run {
                    errorMessage = "Invalid or expired code. Please check and try again."
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        showError = true
                    }
                }
            }
            await MainActor.run {
                isJoining = false
            }
        }
    }

    private func clearError() {
        showError = false
        errorMessage = nil
    }
}

#Preview {
    InvitePartnerView()
        .environmentObject(AppViewModel())
}
