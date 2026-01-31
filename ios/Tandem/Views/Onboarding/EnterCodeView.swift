import SwiftUI

struct EnterCodeView: View {
    let onValidated: (_ code: String, _ senderName: String) -> Void
    let onBack: () -> Void

    @State private var codeCharacters: [String] = Array(repeating: "", count: 6)
    @State private var fullCode: String = ""
    @State private var isValidating = false
    @State private var errorMessage: String?
    @State private var showError = false
    @State private var contentOpacity: Double = 0
    @State private var contentOffset: CGFloat = 20
    @State private var shakeOffset: CGFloat = 0

    @FocusState private var isTextFieldFocused: Bool

    private var activeIndex: Int {
        let idx = fullCode.count
        return min(idx, 5)
    }

    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Navigation Bar
            navigationBar
                .padding(.top, TandemSpacing.md)

            ScrollView {
                VStack(spacing: TandemSpacing.lg) {
                    // MARK: - Header
                    headerSection
                        .padding(.top, TandemSpacing.xl)

                    // MARK: - Code Input
                    codeInputSection
                        .padding(.horizontal, TandemSpacing.xl)

                    // MARK: - Error
                    if showError, let errorMessage = errorMessage {
                        errorBanner(message: errorMessage)
                            .padding(.horizontal, TandemSpacing.xl)
                            .transition(.asymmetric(
                                insertion: .move(edge: .top).combined(with: .opacity),
                                removal: .opacity
                            ))
                    }

                    // MARK: - Validate Button
                    validateButton
                        .padding(.horizontal, TandemSpacing.xl)
                        .padding(.top, TandemSpacing.sm)

                    // MARK: - Help Text
                    helpText

                    Spacer(minLength: TandemSpacing.xl)
                }
                .opacity(contentOpacity)
                .offset(y: contentOffset)
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .background(TandemColors.background.ignoresSafeArea())
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.1)) {
                contentOpacity = 1.0
                contentOffset = 0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                isTextFieldFocused = true
            }
        }
    }

    // MARK: - Navigation Bar

    private var navigationBar: some View {
        HStack {
            Button(action: onBack) {
                HStack(spacing: TandemSpacing.xs) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                    Text("Back")
                        .font(TandemFonts.body)
                }
                .foregroundColor(TandemColors.primary)
            }

            Spacer()
        }
        .padding(.horizontal, TandemSpacing.xl)
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(spacing: TandemSpacing.sm) {
            ZStack {
                Circle()
                    .fill(TandemColors.accent.opacity(0.15))
                    .frame(width: 88, height: 88)

                Image(systemName: "ticket.fill")
                    .font(.system(size: 36))
                    .foregroundStyle(
                        LinearGradient(
                            gradient: Gradient(colors: [TandemColors.accent, TandemColors.primary]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            .padding(.bottom, TandemSpacing.xs)

            Text("Enter Your Invite Code")
                .font(TandemFonts.title)
                .foregroundColor(TandemColors.textPrimary)

            Text("Your partner shared a 6-character code with you")
                .font(TandemFonts.body)
                .foregroundColor(TandemColors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, TandemSpacing.xl)
        }
    }

    // MARK: - Code Input Section

    private var codeInputSection: some View {
        ZStack {
            // Hidden text field that captures input
            TextField("", text: $fullCode)
                .keyboardType(.asciiCapable)
                .textInputAutocapitalization(.characters)
                .autocorrectionDisabled()
                .focused($isTextFieldFocused)
                .frame(width: 1, height: 1)
                .opacity(0.01)
                .onChange(of: fullCode) { _, newValue in
                    let filtered = String(
                        newValue
                            .uppercased()
                            .filter { $0.isLetter || $0.isNumber }
                            .prefix(6)
                    )
                    if filtered != newValue {
                        fullCode = filtered
                    }
                    updateCharacters()
                    clearError()
                }

            // Visual code boxes
            HStack(spacing: TandemSpacing.sm) {
                ForEach(0..<6, id: \.self) { index in
                    codeBox(at: index)
                }
            }
            .offset(x: shakeOffset)
            .contentShape(Rectangle())
            .onTapGesture {
                isTextFieldFocused = true
            }
        }
    }

    private func codeBox(at index: Int) -> some View {
        let character = index < codeCharacters.count ? codeCharacters[index] : ""
        let isFilled = !character.isEmpty
        let isActive = index == activeIndex && isTextFieldFocused

        return Text(character)
            .font(.system(size: 28, weight: .bold, design: .monospaced))
            .foregroundColor(TandemColors.textPrimary)
            .frame(width: 48, height: 60)
            .background(
                RoundedRectangle(cornerRadius: TandemCornerRadius.small)
                    .fill(isFilled ? TandemColors.primary.opacity(0.06) : Color.white)
            )
            .overlay(
                RoundedRectangle(cornerRadius: TandemCornerRadius.small)
                    .stroke(
                        isActive
                            ? TandemColors.primary
                            : isFilled
                                ? TandemColors.primary.opacity(0.3)
                                : TandemColors.textSecondary.opacity(0.2),
                        lineWidth: isActive ? 2 : 1.5
                    )
            )
            .shadow(
                color: isActive
                    ? TandemColors.primary.opacity(0.15)
                    : Color.clear,
                radius: 6,
                x: 0,
                y: 2
            )
            .animation(.easeInOut(duration: 0.15), value: isFilled)
            .animation(.easeInOut(duration: 0.15), value: isActive)
    }

    // MARK: - Validate Button

    private var validateButton: some View {
        Button(action: validateCode) {
            HStack(spacing: TandemSpacing.sm) {
                if isValidating {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.9)
                } else {
                    Text("Validate")
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 16, weight: .semibold))
                }
            }
            .tandemButton()
        }
        .disabled(fullCode.count != 6 || isValidating)
        .opacity(fullCode.count == 6 ? 1.0 : 0.5)
        .animation(.easeInOut(duration: 0.2), value: fullCode.count)
        .animation(.easeInOut(duration: 0.2), value: isValidating)
    }

    // MARK: - Help Text

    private var helpText: some View {
        VStack(spacing: TandemSpacing.xs) {
            Text("Don't have a code?")
                .font(TandemFonts.caption)
                .foregroundColor(TandemColors.textSecondary)

            Text("Ask your partner to share their invite code from the app.")
                .font(TandemFonts.caption)
                .foregroundColor(TandemColors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, TandemSpacing.xl)
        }
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

    // MARK: - Actions

    private func updateCharacters() {
        let chars = Array(fullCode)
        for i in 0..<6 {
            codeCharacters[i] = i < chars.count ? String(chars[i]) : ""
        }
    }

    private func validateCode() {
        guard fullCode.count == 6, !isValidating else { return }
        isTextFieldFocused = false
        isValidating = true
        clearError()

        Task {
            do {
                let response = try await APIService.shared.validateCode(code: fullCode)
                if response.valid {
                    await MainActor.run {
                        isValidating = false
                        onValidated(fullCode, response.senderName)
                    }
                } else {
                    await MainActor.run {
                        showValidationError("This code is invalid or has expired.")
                    }
                }
            } catch {
                await MainActor.run {
                    showValidationError(error.localizedDescription)
                }
            }
        }
    }

    private func showValidationError(_ message: String) {
        isValidating = false
        errorMessage = message
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            showError = true
        }
        // Shake animation
        withAnimation(.spring(response: 0.1, dampingFraction: 0.2)) {
            shakeOffset = 10
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.spring(response: 0.1, dampingFraction: 0.2)) {
                shakeOffset = -10
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.spring(response: 0.15, dampingFraction: 0.5)) {
                shakeOffset = 0
            }
        }
    }

    private func clearError() {
        showError = false
        errorMessage = nil
    }
}

#Preview {
    EnterCodeView(
        onValidated: { code, name in
            print("Code: \(code), Name: \(name)")
        },
        onBack: {}
    )
}
