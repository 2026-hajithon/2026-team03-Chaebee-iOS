import SwiftUI

struct OnboardingFlowView: View {
    enum Step: Equatable {
        case welcome
        case passportSelection
        case passportGuide
        case unsupportedNationality
    }

    @State private var step: Step = .welcome
    @State private var isAuthenticated = false
    @StateObject private var authenticationViewModel: OnboardingAuthenticationViewModel

    let onComplete: (Bool) -> Void

    init(
        authenticationRepository: any AuthenticationRepository,
        googleSignInService: any GoogleSignInServicing,
        onComplete: @escaping (Bool) -> Void
    ) {
        _authenticationViewModel = StateObject(
            wrappedValue: OnboardingAuthenticationViewModel(
                repository: authenticationRepository,
                googleSignInService: googleSignInService
            )
        )
        self.onComplete = onComplete
    }

    var body: some View {
        ZStack {
            CBColor.gray1
                .ignoresSafeArea()

            switch step {
            case .welcome:
                WelcomeView(
                    isLoading: authenticationViewModel.isLoading,
                    errorMessage: authenticationViewModel.errorMessage,
                    onGoogleLogin: {
                        Task {
                            guard let session = await authenticationViewModel.signInWithGoogle() else {
                                return
                            }
                            handleAuthentication(session)
                        }
                    },
                    onAppleLogin: {
                        authenticationViewModel.showAppleLoginUnavailable()
                    },
                    onContinueAsGuest: {
                        Task {
                            guard let session = await authenticationViewModel.continueAsGuest() else {
                                return
                            }
                            handleAuthentication(session)
                        }
                    }
                )

            case .passportSelection:
                PassportSelectionView(
                    onBack: { step = .welcome },
                    onKoreanPassportSelected: { step = .passportGuide },
                    onUnsupportedSelected: { step = .unsupportedNationality }
                )

            case .passportGuide:
                PassportGuideView(
                    onBack: { step = .passportSelection },
                    onConfirm: { onComplete(isAuthenticated) }
                )

            case .unsupportedNationality:
                OnboardingCompleteView(
                    onBack: { step = .passportSelection },
                    onConfirm: { onComplete(isAuthenticated) }
                )
            }
        }
        .animation(.easeInOut(duration: CBAnimation.standardDuration), value: step)
    }

    private func moveToPassportSelection() {
        withAnimation(.easeInOut(duration: CBAnimation.standardDuration)) {
            step = .passportSelection
        }
    }

    private func handleAuthentication(_ session: AuthenticationSession) {
        isAuthenticated = !session.isGuest
        moveToPassportSelection()
    }
}

struct OnboardingNavigationHeader: View {
    let currentStep: Int
    let totalSteps: Int
    let onBack: () -> Void

    var body: some View {
        HStack {
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(CBColor.gray9)
                    .frame(width: 44, height: 44)
                    .background(Color.white, in: Circle())
                    .shadow(
                        color: CBShadow.subtle.color,
                        radius: CBShadow.subtle.radius,
                        x: CBShadow.subtle.x,
                        y: CBShadow.subtle.y
                    )
            }
            .buttonStyle(.plain)
            .accessibilityLabel(Text("common.back"))

            Spacer()

            HStack(spacing: 2) {
                Text(verbatim: "\(currentStep)")
                    .foregroundStyle(CBColor.blue5)
                Text(verbatim: "/ \(totalSteps)")
                    .foregroundStyle(CBColor.gray5)
            }
            .cbTypography(.body3)
        }
    }
}

struct OnboardingChoiceButton: View {
    enum Symbol {
        case no
        case yes
        case confirm

        var systemName: String? {
            switch self {
            case .no: "xmark"
            case .yes: "circle"
            case .confirm: "checkmark"
            }
        }
    }

    let title: LocalizedStringKey
    let variant: CBButton.Variant
    let symbol: Symbol
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: CBSpacing.small) {
                if let systemName = symbol.systemName {
                    Image(systemName: systemName)
                        .font(.system(size: 17, weight: .medium))
                }
                Text(title)
            }
            .cbTypography(.head2)
            .foregroundStyle(variant == .primary ? Color.white : CBColor.blue5)
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .background(
                variant == .primary ? CBColor.blue5 : CBColor.blue1,
                in: RoundedRectangle(cornerRadius: CBRadius.medium)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    OnboardingFlowView(
        authenticationRepository: AppEnvironment.live().authenticationRepository,
        googleSignInService: GoogleSignInService(),
        onComplete: { _ in }
    )
        .environment(\.locale, Locale(identifier: "ko"))
}
