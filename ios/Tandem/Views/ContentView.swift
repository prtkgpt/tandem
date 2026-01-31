import SwiftUI

// MARK: - Onboarding Step

enum OnboardingStep: Equatable {
    case welcome
    case enterCode
    case welcomePartner
    case createAccount
}

// MARK: - ContentView

struct ContentView: View {
    @EnvironmentObject var appViewModel: AppViewModel

    // Local onboarding navigation state
    @State private var onboardingStep: OnboardingStep = .welcome

    // Data passed between onboarding screens
    @State private var inviteCode: String?
    @State private var partnerName: String?
    @State private var startAsSignIn = false

    // Allow skipping the pairing screen
    @State private var skippedPairing = false

    var body: some View {
        ZStack {
            TandemColors.background
                .ignoresSafeArea()

            if appViewModel.isLoading {
                // MARK: - Loading
                loadingView
                    .transition(.opacity)
            } else if !appViewModel.isAuthenticated {
                // MARK: - Onboarding Flow (not authenticated)
                onboardingFlow
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
            } else if !appViewModel.isPaired && !skippedPairing {
                // MARK: - Invite Partner (authenticated, not paired)
                InvitePartnerView(onSkip: {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.85)) {
                        skippedPairing = true
                    }
                })
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))
            } else {
                // MARK: - Main App (authenticated and paired, or skipped)
                MainTabView()
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
            }
        }
        .animation(.spring(response: 0.5, dampingFraction: 0.85), value: appViewModel.isLoading)
        .animation(.spring(response: 0.5, dampingFraction: 0.85), value: appViewModel.isAuthenticated)
        .animation(.spring(response: 0.5, dampingFraction: 0.85), value: appViewModel.isPaired)
        .animation(.spring(response: 0.5, dampingFraction: 0.85), value: skippedPairing)
        .onChange(of: appViewModel.isAuthenticated) { _, isAuth in
            if !isAuth {
                // Reset onboarding state when logged out
                resetOnboardingState()
            }
        }
    }

    // MARK: - Onboarding Flow

    @ViewBuilder
    private var onboardingFlow: some View {
        ZStack {
            if onboardingStep == .enterCode {
                EnterCodeView(
                    onValidated: { code, senderName in
                        inviteCode = code
                        partnerName = senderName
                        withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
                            onboardingStep = .welcomePartner
                        }
                    },
                    onBack: {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                            onboardingStep = .welcome
                        }
                    }
                )
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))
            } else if onboardingStep == .welcomePartner {
                WelcomePartnerView(
                    senderName: partnerName ?? "",
                    onContinue: {
                        startAsSignIn = false
                        withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
                            onboardingStep = .createAccount
                        }
                    }
                )
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))
            } else if onboardingStep == .createAccount {
                CreateAccountView(
                    inviteCode: inviteCode,
                    partnerName: partnerName,
                    initialSignInMode: startAsSignIn
                )
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))
            } else {
                WelcomeView(
                    onGetStarted: {
                        inviteCode = nil
                        partnerName = nil
                        startAsSignIn = false
                        withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
                            onboardingStep = .createAccount
                        }
                    },
                    onEnterCode: {
                        withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
                            onboardingStep = .enterCode
                        }
                    },
                    onSignIn: {
                        inviteCode = nil
                        partnerName = nil
                        startAsSignIn = true
                        withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
                            onboardingStep = .createAccount
                        }
                    }
                )
                .transition(.asymmetric(
                    insertion: .move(edge: .leading).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))
            }
        }
    }

    // MARK: - Loading View

    private var loadingView: some View {
        VStack(spacing: TandemSpacing.lg) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [TandemColors.primary, TandemColors.accent]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)

                Image(systemName: "heart.fill")
                    .font(.system(size: 36))
                    .foregroundColor(.white)
            }

            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: TandemColors.primary))
                .scaleEffect(1.2)

            Text("Loading your world together...")
                .font(TandemFonts.body)
                .foregroundColor(TandemColors.textSecondary)
        }
    }

    // MARK: - Helpers

    private func resetOnboardingState() {
        onboardingStep = .welcome
        inviteCode = nil
        partnerName = nil
        startAsSignIn = false
        skippedPairing = false
    }
}

#Preview {
    ContentView()
        .environmentObject(AppViewModel())
}
