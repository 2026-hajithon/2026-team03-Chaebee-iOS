import SwiftUI

struct TimelinePhaseRow: View {
    let phase: TimelinePhase
    let showsTrailingLine: Bool
    let onToggle: (Int) -> Void

    var body: some View {
        HStack(alignment: .top, spacing: CBSpacing.small) {
            marker
                .frame(width: 72)

            phaseCard
        }
        .overlay(alignment: .topLeading) {
            if showsTrailingLine {
                Rectangle()
                    .fill(CBColor.gray3)
                    .frame(width: 1)
                    .padding(.top, 14)
                    .padding(.bottom, -CBSpacing.large)
                    .offset(x: 4)
            }
        }
    }

    private var marker: some View {
        ZStack(alignment: .topLeading) {
            Circle()
                .fill(CBColor.gray1)
                .overlay {
                    Circle()
                        .stroke(phase.isCurrent ? CBColor.blue5 : CBColor.gray4, lineWidth: 2)
                }
                .frame(width: 9, height: 9)
                .padding(.top, 5)

            VStack(alignment: .leading, spacing: 2) {
                Text(verbatim: phase.label)
                    .cbTypography(.head2)
                    .foregroundStyle(phase.isCurrent ? CBColor.blue5 : CBColor.gray7)

                Text(phase.date, format: .dateTime.month(.twoDigits).day(.twoDigits).weekday(.abbreviated))
                    .cbTypography(.body1)
                    .foregroundStyle(CBColor.gray6)
            }
            .padding(.leading, 17)
        }
    }

    private var phaseCard: some View {
        VStack(spacing: 0) {
            ForEach(phase.discoveries) { discovery in
                discoveryCard(discovery)
                    .padding(.horizontal, CBSpacing.small)
                    .padding(.top, CBSpacing.small)
            }

            ForEach(Array(phase.checklistItems.enumerated()), id: \.element.id) { index, item in
                if index > 0 || !phase.discoveries.isEmpty {
                    Divider()
                        .overlay(CBColor.gray2)
                        .padding(.leading, 42)
                }

                checklistRow(item)
            }
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: CBRadius.medium))
        .overlay {
            RoundedRectangle(cornerRadius: CBRadius.medium)
                .stroke(phase.isCurrent ? CBColor.blue5 : CBColor.gray3, lineWidth: phase.isCurrent ? 2 : 1)
                .allowsHitTesting(false)
        }
        .padding(.bottom, CBSpacing.large)
    }

    private func discoveryCard(_ discovery: TimelineDiscovery) -> some View {
        VStack(alignment: .leading, spacing: CBSpacing.xSmall) {
            Text(discovery.tag.localizedName)
                .cbTypography(.subhead2)
                .foregroundStyle(CBColor.blue5)

            if let title = discovery.title, !title.isEmpty {
                Text(verbatim: title)
                    .cbTypography(.subhead2)
                    .foregroundStyle(CBColor.gray8)
            }

            Text(verbatim: discovery.content)
                .cbTypography(.body2)
                .foregroundStyle(CBColor.gray7)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(CBSpacing.small)
        .background(CBColor.blue1)
        .clipShape(RoundedRectangle(cornerRadius: CBRadius.small))
    }

    private func checklistRow(_ item: TimelineChecklistItem) -> some View {
        HStack(spacing: CBSpacing.small) {
            Button {
                onToggle(item.id)
            } label: {
                HStack(spacing: CBSpacing.small) {
                    Image(systemName: item.isChecked ? "checkmark.square.fill" : "square")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundStyle(item.isChecked ? CBColor.blue5 : CBColor.gray3)

                    Text(verbatim: item.title)
                        .cbTypography(.body2)
                        .foregroundStyle(item.isChecked ? CBColor.gray7 : CBColor.gray5)
                        .strikethrough(item.isChecked, color: CBColor.gray5)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel(Text(verbatim: item.title))
            .accessibilityValue(
                Text(item.isChecked ? "common.checked" : "common.unchecked")
            )

            if let actionTitle = item.actionTitle, let actionURL = item.actionURL {
                Link(destination: actionURL) {
                    Text(verbatim: actionTitle)
                        .cbTypography(.subhead1)
                        .foregroundStyle(Color.white)
                        .padding(.horizontal, CBSpacing.small)
                        .frame(height: 26)
                        .background(CBColor.blue5)
                        .clipShape(Capsule())
                }
                .accessibilityLabel(Text(verbatim: "\(item.title), \(actionTitle)"))
            }
        }
        .padding(CBSpacing.small)
        .frame(minHeight: 48)
    }
}
