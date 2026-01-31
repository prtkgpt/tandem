import SwiftUI

// MARK: - Field Enum

enum CreateAccountField: Hashable {
    case name, email, password
}

// MARK: - CreateAccountView

struct CreateAccountView: View {
    @EnvironmentObject var appViewModel: AppViewModel

    /// Invite code from Partner B flow (nil for Partner A)
    var inviteCode: String?

    /// Partner name to display in the banner (Partner B flow)
    var partnerName: String?

    /// If true, start with Sign In selected instead of Sign Up
    var initialSignInMode: Bool

    @State private var isSignUp: Bool
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showError = false
    @State private var contentOpacity: Double = 0
    @State private var contentOffset: CGFloat = 15

    @State private var isPasswordRevealed = false

    @FocusState private var focusedField: CreateAccountField?

    init(inviteCode: String? = nil, partnerName: String? = nil, initialSignInMode: Bool = false) {
        self.inviteCode = inviteCode
        self.partnerName = partnerName
        self.initialSignInMode = initialSignInMode
        self._isSignUp = State(initialValue: !initialSignInMode)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: TandemSpacing.lg) {
                // MARK: - Header
                headerSection
                    .padding(.top, TandemSpacing.xl)

                // MARK: - Partner Banner (Partner B flow)
                if let partnerName = partnerName, inviteCode != nil {
                    partnerBanner(name: partnerName)
                        .padding(.horizontal, TandemSpacing.xl)
                }

                // MARK: - Mode Toggle
                modeToggle
                    .padding(.horizontal, TandemSpacing.xl)

                // MARK: - Form Fields
                formFields
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

                // MARK: - Submit Button
                submitButton
                    .padding(.horizontal, TandemSpacing.xl)
                    .padding(.top, TandemSpacing.sm)

                Spacer(minLength: TandemSpacing.xl)
            }
            .opacity(contentOpacity)
            .offset(y: contentOffset)
        }
        .background(TandemColors.background.ignoresSafeArea())
        .scrollDismissesKeyboard(.interactively)
        .onTapGesture {
            focusedField = nil
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.1)) {
                contentOpacity = 1.0
                contentOffset = 0
            }
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(spacing: TandemSpacing.sm) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                TandemColors.primary.opacity(0.12),
                                TandemColors.accent.opacity(0.08)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 88, height: 88)

                Image(systemName: isSignUp ? "person.badge.plus" : "person.crop.circle.fill")
                    .font(.system(size: 38))
                    .foregroundStyle(
                        LinearGradient(
                            gradient: Gradient(colors: [TandemColors.primary, TandemColors.accent]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: isSignUp)

            Text(isSignUp ? "Create Your Account" : "Welcome Back")
                .font(TandemFonts.title)
                .foregroundColor(TandemColors.textPrimary)

            Text(isSignUp
                ? "Start your journey together"
                : "Sign in to continue your journey")
                .font(TandemFonts.body)
                .foregroundColor(TandemColors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isSignUp)
    }

    // MARK: - Partner Banner

    private func partnerBanner(name: String) -> some View {
        HStack(spacing: TandemSpacing.sm) {
            Image(systemName: "heart.fill")
                .font(.system(size: 14))
                .foregroundColor(TandemColors.primary)

            Text("Joining \(name)\u{2019}s couple")
                .font(TandemFonts.body)
                .foregroundColor(TandemColors.primary)
                .fontWeight(.medium)

            Spacer()

            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 16))
                .foregroundColor(TandemColors.secondary)
        }
        .padding(TandemSpacing.md)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    TandemColors.primary.opacity(0.08),
                    TandemColors.accent.opacity(0.06)
                ]),
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .cornerRadius(TandemCornerRadius.button)
        .overlay(
            RoundedRectangle(cornerRadius: TandemCornerRadius.button)
                .stroke(TandemColors.primary.opacity(0.15), lineWidth: 1)
        )
    }

    // MARK: - Mode Toggle

    private var modeToggle: some View {
        HStack(spacing: 0) {
            toggleButton(title: "Sign Up", isActive: isSignUp) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    isSignUp = true
                    clearError()
                }
            }

            toggleButton(title: "Sign In", isActive: !isSignUp) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    isSignUp = false
                    clearError()
                }
            }
        }
        .background(TandemColors.textSecondary.opacity(0.1))
        .cornerRadius(TandemCornerRadius.button)
    }

    private func toggleButton(title: String, isActive: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(TandemFonts.headline)
                .foregroundColor(isActive ? .white : TandemColors.textSecondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, TandemSpacing.sm + 2)
                .background(
                    Group {
                        if isActive {
                            LinearGradient(
                                gradient: Gradient(colors: [TandemColors.primary, TandemColors.accent]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        } else {
                            Color.clear
                        }
                    }
                )
                .cornerRadius(TandemCornerRadius.button)
        }
    }

    // MARK: - Form Fields

    private var formFields: some View {
        VStack(spacing: TandemSpacing.md) {
            // Name field (sign up only)
            if isSignUp {
                styledTextField(
                    icon: "person.fill",
                    placeholder: "Your Name",
                    text: $name,
                    field: .name,
                    contentType: .name,
                    keyboardType: .default,
                    autocapitalize: true
                )
                .submitLabel(.next)
                .onSubmit { focusedField = .email }
                .transition(.asymmetric(
                    insertion: .move(edge: .top).combined(with: .opacity),
                    removal: .move(edge: .top).combined(with: .opacity)
                ))
            }

            // Email field
            styledTextField(
                icon: "envelope.fill",
                placeholder: "Email Address",
                text: $email,
                field: .email,
                contentType: .emailAddress,
                keyboardType: .emailAddress,
                autocapitalize: false
            )
            .submitLabel(.next)
            .onSubmit { focusedField = .password }

            // Password field
            styledSecureField(
                icon: "lock.fill",
                placeholder: "Password",
                text: $password,
                field: .password
            )
            .submitLabel(.go)
            .onSubmit { submitForm() }
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: isSignUp)
    }

    // MARK: - Styled Text Field

    private func styledTextField(
        icon: String,
        placeholder: String,
        text: Binding<String>,
        field: CreateAccountField,
        contentType: UITextContentType?,
        keyboardType: UIKeyboardType,
        autocapitalize: Bool
    ) -> some View {
        HStack(spacing: TandemSpacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(
                    focusedField == field
                        ? TandemColors.primary
                        : TandemColors.textSecondary
                )
                .frame(width: 24)

            TextField(placeholder, text: text)
                .font(TandemFonts.body)
                .foregroundColor(TandemColors.textPrimary)
                .textContentType(contentType)
                .keyboardType(keyboardType)
                .textInputAutocapitalization(autocapitalize ? .words : .never)
                .autocorrectionDisabled()
                .focused($focusedField, equals: field)
        }
        .padding(TandemSpacing.md)
        .background(Color.white)
        .cornerRadius(TandemCornerRadius.button)
        .overlay(
            RoundedRectangle(cornerRadius: TandemCornerRadius.button)
                .stroke(
                    focusedField == field
                        ? TandemColors.primary.opacity(0.5)
                        : Color.clear,
                    lineWidth: 1.5
                )
        )
        .shadow(
            color: focusedField == field
                ? TandemColors.primary.opacity(0.1)
                : Color.black.opacity(0.04),
            radius: focusedField == field ? 8 : 4,
            x: 0,
            y: 2
        )
        .animation(.easeInOut(duration: 0.2), value: focusedField)
    }

    // MARK: - Styled Secure Field

    private func styledSecureField(
        icon: String,
        placeholder: String,
        text: Binding<String>,
        field: CreateAccountField
    ) -> some View {
        HStack(spacing: TandemSpacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(
                    focusedField == field
                        ? TandemColors.primary
                        : TandemColors.textSecondary
                )
                .frame(width: 24)

            Group {
                if isPasswordRevealed {
                    TextField(placeholder, text: text)
                        .textContentType(isSignUp ? .newPassword : .password)
                } else {
                    SecureField(placeholder, text: text)
                        .textContentType(isSignUp ? .newPassword : .password)
                }
            }
            .font(TandemFonts.body)
            .foregroundColor(TandemColors.textPrimary)
            .focused($focusedField, equals: field)

            Button {
                isPasswordRevealed.toggle()
            } label: {
                Image(systemName: isPasswordRevealed ? "eye.slash.fill" : "eye.fill")
                    .font(.system(size: 15))
                    .foregroundColor(TandemColors.textSecondary)
            }
        }
        .padding(TandemSpacing.md)
        .background(Color.white)
        .cornerRadius(TandemCornerRadius.button)
        .overlay(
            RoundedRectangle(cornerRadius: TandemCornerRadius.button)
                .stroke(
                    focusedField == field
                        ? TandemColors.primary.opacity(0.5)
                        : Color.clear,
                    lineWidth: 1.5
                )
        )
        .shadow(
            color: focusedField == field
                ? TandemColors.primary.opacity(0.1)
                : Color.black.opacity(0.04),
            radius: focusedField == field ? 8 : 4,
            x: 0,
            y: 2
        )
        .animation(.easeInOut(duration: 0.2), value: focusedField)
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

    // MARK: - Submit Button

    private var submitButton: some View {
        Button(action: submitForm) {
            HStack(spacing: TandemSpacing.sm) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.9)
                } else {
                    Text(isSignUp ? "Create Account" : "Sign In")

                    Image(systemName: isSignUp ? "arrow.right" : "arrow.right.to.line")
                        .font(.system(size: 14, weight: .semibold))
                }
            }
            .tandemButton()
        }
        .disabled(isLoading || !isFormValid)
        .opacity(isFormValid ? 1.0 : 0.6)
        .animation(.easeInOut(duration: 0.2), value: isFormValid)
        .animation(.easeInOut(duration: 0.2), value: isLoading)
    }

    // MARK: - Validation

    private var isFormValid: Bool {
        let emailValid = email.contains("@") && email.contains(".")
        let passwordValid = password.count >= 6
        if isSignUp {
            return !name.trimmingCharacters(in: .whitespaces).isEmpty && emailValid && passwordValid
        }
        return emailValid && passwordValid
    }

    // MARK: - Actions

    private func submitForm() {
        guard isFormValid, !isLoading else { return }
        focusedField = nil
        isLoading = true
        clearError()

        Task {
            do {
                if isSignUp {
                    try await appViewModel.register(
                        name: name.trimmingCharacters(in: .whitespaces),
                        email: email.lowercased().trimmingCharacters(in: .whitespaces),
                        password: password,
                        inviteCode: inviteCode
                    )
                } else {
                    try await appViewModel.login(
                        email: email.lowercased().trimmingCharacters(in: .whitespaces),
                        password: password
                    )
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        showError = true
                    }
                }
            }
            await MainActor.run {
                isLoading = false
            }
        }
    }

    private func clearError() {
        showError = false
        errorMessage = nil
    }
}

#Preview("Sign Up") {
    CreateAccountView()
        .environmentObject(AppViewModel())
}

#Preview("Partner B Flow") {
    CreateAccountView(
        inviteCode: "ABC123",
        partnerName: "Alex"
    )
    .environmentObject(AppViewModel())
}

#Preview("Sign In") {
    CreateAccountView(initialSignInMode: true)
        .environmentObject(AppViewModel())
}
