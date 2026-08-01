import SwiftUI

/// A single-line text field using Chaebee's input styles.
///
/// Default, editing, and filled appearances are determined automatically.
/// Provide an `errorMessage` to display the failed appearance.
struct CBTextField: View {
    @Environment(\.isEnabled) private var isEnabled
    @FocusState private var isFocused: Bool

    @Binding private var text: String

    private let placeholder: LocalizedStringKey
    private let errorMessage: LocalizedStringKey?
    private let trailingSystemImage: String?
    private let onTrailingTap: (() -> Void)?
    private let autoFocus: Bool
    private let previewState: CBTextFieldVisualState?

    init(
        text: Binding<String>,
        placeholder: LocalizedStringKey,
        errorMessage: LocalizedStringKey? = nil,
        trailingSystemImage: String? = nil,
        onTrailingTap: (() -> Void)? = nil,
        autoFocus: Bool = false
    ) {
        _text = text
        self.placeholder = placeholder
        self.errorMessage = errorMessage
        self.trailingSystemImage = trailingSystemImage
        self.onTrailingTap = onTrailingTap
        self.autoFocus = autoFocus
        previewState = nil
    }

    fileprivate init(
        text: Binding<String>,
        placeholder: LocalizedStringKey,
        errorMessage: LocalizedStringKey? = nil,
        trailingSystemImage: String? = nil,
        previewState: CBTextFieldVisualState
    ) {
        _text = text
        self.placeholder = placeholder
        self.errorMessage = errorMessage
        self.trailingSystemImage = trailingSystemImage
        onTrailingTap = nil
        autoFocus = false
        self.previewState = previewState
    }

    private var visualState: CBTextFieldVisualState {
        if let previewState {
            return previewState
        }

        if !isEnabled {
            return .disabled
        }

        if errorMessage != nil {
            return .failed
        }

        if isFocused {
            return .editing
        }

        return text.isEmpty ? .default : .filled
    }

    var body: some View {
        VStack(alignment: .leading, spacing: CBSpacing.small) {
            HStack(spacing: CBSpacing.small) {
                TextField(
                    "",
                    text: $text,
                    prompt: Text(placeholder)
                        .foregroundColor(CBColor.gray4)
                )
                .cbTypography(.body4)
                .foregroundStyle(textColor)
                .tint(CBColor.blue5)
                .focused($isFocused)

                trailingIcon
            }
            .padding(.horizontal, CBSpacing.medium)
            .frame(height: 48)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: CBRadius.medium))
            .overlay {
                RoundedRectangle(cornerRadius: CBRadius.medium)
                    .strokeBorder(borderColor, lineWidth: borderWidth)
            }

            if let errorMessage {
                Text(errorMessage)
                    .cbTypography(.caption1)
                    .foregroundStyle(CBColor.red)
                    .padding(.horizontal, CBSpacing.small)
            }
        }
        .animation(
            .easeOut(duration: CBAnimation.quickDuration),
            value: visualState
        )
        .task {
            guard autoFocus else { return }
            await Task.yield()
            isFocused = true
        }
    }

    @ViewBuilder
    private var trailingIcon: some View {
        if let trailingSystemImage {
            if let onTrailingTap {
                Button(action: onTrailingTap) {
                    trailingIconImage(trailingSystemImage)
                }
                .buttonStyle(.plain)
            } else {
                trailingIconImage(trailingSystemImage)
                    .accessibilityHidden(true)
            }
        }
    }

    private func trailingIconImage(_ systemName: String) -> some View {
        Image(systemName: systemName)
            .font(.system(size: 20, weight: .medium))
            .foregroundStyle(trailingIconColor)
            .frame(width: 24, height: 24)
    }

    private var borderColor: Color {
        switch visualState {
        case .editing:
            CBColor.blue5
        case .failed:
            CBColor.red
        case .default, .filled, .disabled:
            CBColor.gray3
        }
    }

    private var borderWidth: CGFloat {
        switch visualState {
        case .editing, .failed:
            1.5
        case .default, .filled, .disabled:
            1
        }
    }

    private var textColor: Color {
        visualState == .disabled ? CBColor.gray4 : CBColor.gray8
    }

    private var trailingIconColor: Color {
        visualState == .disabled ? CBColor.gray4 : CBColor.blue5
    }

    private var backgroundColor: Color {
        visualState == .disabled ? CBColor.gray1 : Color.white
    }
}

fileprivate enum CBTextFieldVisualState: Equatable {
    case `default`
    case editing
    case filled
    case failed
    case disabled
}

#Preview("CBTextField states") {
    CBTextFieldPreview()
}

private struct CBTextFieldPreview: View {
    @State private var emptyText = ""
    @State private var editingText = "입력중"
    @State private var filledText = "입력됨"
    @State private var failedText = "입력됨"
    @State private var searchText = "로스앤젤레스, 미국"

    var body: some View {
        VStack(spacing: CBSpacing.large) {
            CBTextField(
                text: $emptyText,
                placeholder: "입력",
                previewState: .default
            )

            CBTextField(
                text: $editingText,
                placeholder: "입력",
                previewState: .editing
            )

            CBTextField(
                text: $filledText,
                placeholder: "입력",
                previewState: .filled
            )

            CBTextField(
                text: $failedText,
                placeholder: "입력",
                errorMessage: "최대 100자까지 입력할 수 있어요",
                previewState: .failed
            )

            CBTextField(
                text: $searchText,
                placeholder: "도시 또는 국가 검색",
                trailingSystemImage: "magnifyingglass",
                previewState: .filled
            )
        }
        .padding(CBSpacing.pageHorizontal)
        .background(Color.white)
    }
}
