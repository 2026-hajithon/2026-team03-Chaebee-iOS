import SwiftUI

struct WriteExperienceNavigationHeader: View {
    let isNextEnabled: Bool
    var isLoading = false
    var actionTitle: LocalizedStringKey = "common.next"
    let onClose: () -> Void
    let onNext: () -> Void

    var body: some View {
        ZStack {
            Text("writeExperience.input.title")
                .cbTypography(.head3)
                .foregroundStyle(CBColor.gray9)

            HStack {
                circularButton(
                    systemName: "xmark",
                    foregroundColor: CBColor.gray9,
                    backgroundColor: Color.white,
                    action: onClose
                )
                .accessibilityLabel(Text("common.cancel"))

                Spacer()

                Button(action: onNext) {
                    Group {
                        if isLoading {
                            ProgressView()
                                .tint(Color.white)
                        } else {
                            Text(actionTitle)
                                .cbTypography(.body4)
                                .foregroundStyle(
                                    isNextEnabled ? Color.white : CBColor.gray4
                                )
                        }
                    }
                    .frame(width: 56, height: 56)
                    .background(
                        isNextEnabled || isLoading ? CBColor.blue5 : Color.white,
                        in: Circle()
                    )
                }
                .buttonStyle(.plain)
                .disabled(!isNextEnabled)
            }
        }
        .frame(height: 56)
    }

    private func circularButton(
        systemName: String,
        foregroundColor: Color,
        backgroundColor: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 23, weight: .regular))
                .foregroundStyle(foregroundColor)
                .frame(width: 56, height: 56)
                .background(backgroundColor, in: Circle())
                .shadow(
                    color: CBShadow.subtle.color,
                    radius: CBShadow.subtle.radius,
                    x: CBShadow.subtle.x,
                    y: CBShadow.subtle.y
                )
        }
        .buttonStyle(.plain)
    }
}
