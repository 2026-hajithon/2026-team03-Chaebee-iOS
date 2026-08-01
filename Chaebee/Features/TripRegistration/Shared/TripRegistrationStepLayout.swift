import SwiftUI

/// Shared screen structure for the steps in the trip registration flow.
struct TripRegistrationStepLayout<Content: View>: View {
    @Environment(\.dismiss) private var dismiss

    private let step: LocalizedStringResource
    private let title: LocalizedStringResource
    private let subtitle: LocalizedStringResource?
    private let isNextEnabled: Bool
    private let onNext: () -> Void
    private let content: Content

    init(
        step: LocalizedStringResource = "tripRegistration.step.oneOfFive",
        title: LocalizedStringResource,
        subtitle: LocalizedStringResource? = nil,
        isNextEnabled: Bool,
        onNext: @escaping () -> Void,
        @ViewBuilder content: () -> Content
    ) {
        self.step = step
        self.title = title
        self.subtitle = subtitle
        self.isNextEnabled = isNextEnabled
        self.onNext = onNext
        self.content = content()
    }

    var body: some View {
        ScrollView {
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

                if let subtitle {
                    Text(subtitle)
                        .cbTypography(.body4)
                        .foregroundStyle(CBColor.gray6)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.top, CBSpacing.small)
                }

                content
                    .padding(.top, CBSpacing.xLarge)
            }
            .padding(.horizontal, CBSpacing.pageHorizontal)
            .padding(.top, CBSpacing.medium)
            .padding(.bottom, CBSpacing.xLarge)
        }
        .scrollIndicators(.hidden)
        .background(CBColor.gray1)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            CBButton("common.next", action: onNext)
                .disabled(!isNextEnabled)
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
