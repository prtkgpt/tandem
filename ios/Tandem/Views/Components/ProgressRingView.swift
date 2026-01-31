import SwiftUI

struct ProgressRingView: View {
    let progress: Double
    var lineWidth: CGFloat = 12
    var size: CGFloat = 120
    var label: String = ""

    @State private var animatedProgress: Double = 0

    var body: some View {
        ZStack {
            // Background track
            Circle()
                .stroke(Color.gray.opacity(0.15), lineWidth: lineWidth)

            // Progress arc
            Circle()
                .trim(from: 0, to: animatedProgress)
                .stroke(
                    AngularGradient(
                        gradient: Gradient(colors: [
                            TandemColors.primary,
                            TandemColors.accent,
                            TandemColors.primary
                        ]),
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))

            // Label
            if !label.isEmpty {
                Text(label)
                    .font(.system(size: size * 0.15, weight: .bold, design: .rounded))
                    .foregroundColor(TandemColors.textPrimary)
            }
        }
        .frame(width: size, height: size)
        .onAppear {
            withAnimation(.spring(response: 1.0, dampingFraction: 0.8)) {
                animatedProgress = min(max(progress, 0), 1.0)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 32) {
        ProgressRingView(
            progress: 0.65,
            label: "4.5 / 7 hrs"
        )

        ProgressRingView(
            progress: 0.3,
            lineWidth: 8,
            size: 80,
            label: "30%"
        )

        ProgressRingView(
            progress: 1.0,
            label: "Done!"
        )
    }
    .padding()
}
