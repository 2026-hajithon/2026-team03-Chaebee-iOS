import SwiftUI

struct TagSelectionView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var selectedTag: PreparationTag?
    @State private var content = ""

    private let discoveryID: UUID?
    private let onSave: (ExperienceDraftDiscovery) -> Void
    private let maximumCharacterCount = 100

    init(
        discovery: ExperienceDraftDiscovery? = nil,
        onSave: @escaping (ExperienceDraftDiscovery) -> Void
    ) {
        discoveryID = discovery?.id
        _selectedTag = State(initialValue: discovery?.tag)
        _content = State(initialValue: discovery?.content ?? "")
        self.onSave = onSave
    }

    var body: some View {
        VStack(spacing: 0) {
            editorHeader
                .padding(.horizontal, CBSpacing.pageHorizontal)
                .padding(.top, CBSpacing.small)

            ScrollView {
                VStack(alignment: .leading, spacing: CBSpacing.large) {
                    keywordSection
                    contentSection
                }
                .padding(.horizontal, CBSpacing.pageHorizontal)
                .padding(.vertical, CBSpacing.large)
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .background(Color.white)
        .toolbar(.hidden, for: .navigationBar)
    }

    private var editorHeader: some View {
        ZStack {
            Text("writeExperience.discovery.editor.title")
                .cbTypography(.head3)
                .foregroundStyle(CBColor.gray9)

            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 23, weight: .regular))
                        .foregroundStyle(CBColor.gray6)
                        .frame(width: 56, height: 56)
                        .background(CBColor.gray2, in: Circle())
                }
                .buttonStyle(.plain)

                Spacer()

                Button(action: save) {
                    Text("writeExperience.discovery.editor.save")
                        .cbTypography(.body3)
                        .foregroundStyle(canSave ? Color.white : CBColor.gray4)
                        .frame(width: 56, height: 56)
                        .background(
                            canSave ? CBColor.blue5 : Color.white,
                            in: Circle()
                        )
                }
                .buttonStyle(.plain)
                .disabled(!canSave)
            }
        }
        .frame(height: 56)
    }

    private var keywordSection: some View {
        VStack(alignment: .leading, spacing: CBSpacing.small) {
            Text("writeExperience.discovery.keyword.title")
                .cbTypography(.head2)
                .foregroundStyle(CBColor.gray8)

            Text("writeExperience.discovery.keyword.subtitle")
                .cbTypography(.body3)
                .foregroundStyle(CBColor.gray6)

            CBFlowLayout(
                horizontalSpacing: CBSpacing.small,
                verticalSpacing: CBSpacing.small
            ) {
                ForEach(editableTags, id: \.rawValue) { tag in
                    ExperienceKeywordChip(
                        title: tag.localizedName,
                        icon: tag.iconResource,
                        state: selectedTag == tag ? .selected : .selectable,
                        action: { selectedTag = tag }
                    )
                }
            }
            .padding(.top, CBSpacing.small)
        }
    }

    private var contentSection: some View {
        VStack(alignment: .leading, spacing: CBSpacing.small) {
            Text("writeExperience.discovery.summary.title")
                .cbTypography(.head2)
                .foregroundStyle(CBColor.gray8)

            Text("writeExperience.discovery.summary.subtitle")
                .cbTypography(.body3)
                .foregroundStyle(CBColor.gray6)

            ZStack(alignment: .topLeading) {
                if content.isEmpty {
                    Text("writeExperience.discovery.summary.placeholder")
                        .cbTypography(.body4)
                        .foregroundStyle(CBColor.gray4)
                        .padding(.horizontal, 13)
                        .padding(.vertical, 14)
                        .allowsHitTesting(false)
                }

                TextEditor(text: $content)
                    .cbTypography(.body4)
                    .foregroundStyle(CBColor.gray8)
                    .scrollContentBackground(.hidden)
                    .padding(CBSpacing.small)
                    .frame(minHeight: 160)
            }
            .background(Color.white)
            .overlay {
                RoundedRectangle(cornerRadius: CBRadius.medium)
                    .strokeBorder(CBColor.gray3, lineWidth: 1)
            }

            Text(verbatim: "\(content.count)/\(maximumCharacterCount)")
                .cbTypography(.caption1)
                .foregroundStyle(CBColor.gray5)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .onChange(of: content) { _, newValue in
            if newValue.count > maximumCharacterCount {
                content = String(newValue.prefix(maximumCharacterCount))
            }
        }
    }

    private var canSave: Bool {
        selectedTag != nil && !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private var editableTags: [PreparationTag] {
        [
            .passport, .visa, .vaccination, .insurance,
            .exchange, .transitCard, .adapter, .esimRoaming,
            .entryForm, .flightBoarding, .localAirport
        ]
    }

    private func save() {
        guard let selectedTag else { return }
        onSave(
            ExperienceDraftDiscovery(
                id: discoveryID ?? UUID(),
                tag: selectedTag,
                content: content.trimmingCharacters(in: .whitespacesAndNewlines)
            )
        )
        dismiss()
    }
}

#Preview {
    TagSelectionView(onSave: { _ in })
        .environment(\.locale, Locale(identifier: "ko"))
}
