import SwiftUI

struct TripBinaryQuestionLayout<Illustration: View>: View {
    @Environment(\.dismiss) private var dismiss

    private let step: LocalizedStringResource
    private let title: LocalizedStringResource
    private let onAnswer: (Bool) -> Void
    private let illustration: Illustration

    init(
        step: LocalizedStringResource,
        title: LocalizedStringResource,
        onAnswer: @escaping (Bool) -> Void,
        @ViewBuilder illustration: () -> Illustration
    ) {
        self.step = step
        self.title = title
        self.onAnswer = onAnswer
        self.illustration = illustration()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            backButton

            Text(step)
                .cbTypography(.head2)
                .foregroundStyle(CBColor.blue5)
                .padding(.top, 28)

            Text(title)
                .cbTypography(.head5)
                .foregroundStyle(CBColor.gray9)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, CBSpacing.small)

            Spacer(minLength: CBSpacing.xLarge)

            illustration
                .frame(maxWidth: .infinity, alignment: .center)

            Spacer(minLength: CBSpacing.xLarge)
        }
        .padding(.horizontal, CBSpacing.pageHorizontal)
        .padding(.top, CBSpacing.medium)
        .background(CBColor.gray1)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            VStack(spacing: CBSpacing.small) {
                TripBinaryChoiceButton(
                    "tripRegistration.answer.no",
                    systemName: "xmark",
                    variant: .secondary,
                    action: { onAnswer(false) }
                )

                TripBinaryChoiceButton(
                    "tripRegistration.answer.yesPlan",
                    systemName: "circle",
                    variant: .primary,
                    action: { onAnswer(true) }
                )
            }
            .padding(.horizontal, CBSpacing.pageHorizontal)
            .padding(.top, CBSpacing.small)
            .padding(.bottom, CBSpacing.medium)
            .background(CBColor.gray1)
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    private var backButton: some View {
        Button {
            dismiss()
        } label: {
            Image(systemName: "chevron.left")
                .font(.system(size: 22, weight: .medium))
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
    }
}

private struct TripBinaryChoiceButton: View {
    enum Variant {
        case primary
        case secondary
    }

    let title: LocalizedStringResource
    let systemName: String
    let variant: Variant
    let action: () -> Void

    init(
        _ title: LocalizedStringResource,
        systemName: String,
        variant: Variant,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.systemName = systemName
        self.variant = variant
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: CBSpacing.small) {
                Image(systemName: systemName)
                    .font(.system(size: 20, weight: .semibold))

                Text(title)
                    .cbTypography(.head2)
            }
            .foregroundStyle(foregroundColor)
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: CBRadius.medium))
        }
        .buttonStyle(.plain)
    }

    private var backgroundColor: Color {
        variant == .primary ? CBColor.blue5 : CBColor.blue1
    }

    private var foregroundColor: Color {
        variant == .primary ? .white : CBColor.blue5
    }
}
