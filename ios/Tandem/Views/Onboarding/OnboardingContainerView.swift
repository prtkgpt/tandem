import SwiftUI

struct OnboardingContainerView: View {
    @State private var currentPage = 0

    var body: some View {
        ZStack {
            TandemColors.background
                .ignoresSafeArea()

            VStack(spacing: 0) {
                TabView(selection: $currentPage) {
                    WelcomeView(onGetStarted: {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            currentPage = 1
                        }
                    })
                    .tag(0)

                    CreateAccountView()
                        .tag(1)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .animation(.spring(response: 0.4, dampingFraction: 0.8), value: currentPage)

                // Custom page indicator dots
                pageIndicator
                    .padding(.bottom, TandemSpacing.lg)
            }
        }
    }

    // MARK: - Page Indicator

    private var pageIndicator: some View {
        HStack(spacing: TandemSpacing.sm) {
            ForEach(0..<2, id: \.self) { index in
                Capsule()
                    .fill(index == currentPage ? TandemColors.primary : TandemColors.textSecondary.opacity(0.3))
                    .frame(width: index == currentPage ? 24 : 8, height: 8)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentPage)
            }
        }
    }
}

#Preview {
    OnboardingContainerView()
        .environmentObject(AppViewModel())
}
