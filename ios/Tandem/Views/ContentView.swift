import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appViewModel: AppViewModel

    var body: some View {
        ZStack {
            TandemColors.background
                .ignoresSafeArea()

            if appViewModel.isLoading {
                loadingView
                    .transition(.opacity)
            } else if !appViewModel.isAuthenticated {
                OnboardingContainerView()
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
            } else if !appViewModel.isPaired {
                InvitePartnerView()
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
            } else {
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
}

#Preview {
    ContentView()
        .environmentObject(AppViewModel())
}
