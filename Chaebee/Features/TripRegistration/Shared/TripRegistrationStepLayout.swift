import SwiftUI

/// Shared screen structure for the steps in the trip registration flow.
struct TripRegistrationStepLayout<Content: View>: View {
    @Environment(\.dismiss) private var dismiss

    private let title: LocalizedStringKey
    private let isNextEnabled: Bool
    private let onNext: () -> Void
    private let content: Content

    init(
        title: LocalizedStringKey,
        isNextEnabled: Bool,
        onNext: @escaping () -> Void,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.isNextEnabled = isNextEnabled
        self.onNext = onNext
        self.content = content()
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                backButton

                Text("tripRegistration.step.oneOfFive")
                    .cbTypography(.head2)
                    .foregroundStyle(CBColor.blue5)
                    .padding(.top, 28)

                Text(title)
                    .cbTypography(.head5)
                    .foregroundStyle(CBColor.gray9)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, CBSpacing.small)

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

