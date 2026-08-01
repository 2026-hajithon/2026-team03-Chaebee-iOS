import Foundation
import SwiftUI

struct TimelineSummaryCards: View {
    let progress: TimelineProgress
    let highlight: TimelineHighlight

    var body: some View {
        HStack(spacing: CBSpacing.small) {
            progressCard
            highlightCard
        }
    }

    private var progressCard: some View {
        VStack(alignment: .leading, spacing: CBSpacing.small) {
            ZStack {
                Circle()
                    .stroke(CBColor.gray3, lineWidth: 6)

                Circle()
                    .trim(from: 0, to: progressFraction)
                    .stroke(
                        CBColor.blue5,
                        style: StrokeStyle(lineWidth: 6, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))

                Text(verbatim: "\(progress.done)/\(progress.total)")
                    .cbTypography(.body1)
                    .foregroundStyle(CBColor.gray6)
            }
            .frame(width: 48, height: 48)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(Text("timeline.progress.accessibilityLabel"))
            .accessibilityValue(Text(verbatim: "\(progress.done)/\(progress.total)"))

            Text("timeline.progress.almostDone")
                .cbTypography(.subhead2)
                .foregroundStyle(CBColor.gray8)

            Text(
                verbatim: String(
                    format: String(localized: "timeline.progress.percent"),
                    progress.percent
                )
            )
                .cbTypography(.body1)
                .foregroundStyle(CBColor.gray6)
        }
        .padding(CBSpacing.medium)
        .frame(maxWidth: .infinity, minHeight: 150, alignment: .topLeading)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: CBRadius.large))
    }

    private var highlightCard: some View {
        VStack(alignment: .leading, spacing: CBSpacing.small) {
            Image(highlight.tag.iconResource)
                .resizable()
                .scaledToFit()
                .frame(width: 48, height: 48)

            Text(verbatim: highlight.title)
                .cbTypography(.subhead2)
                .foregroundStyle(CBColor.gray8)
                .lineLimit(2)

            Text(verbatim: highlight.subtitle)
                .cbTypography(.body1)
                .foregroundStyle(CBColor.gray6)
        }
        .padding(CBSpacing.medium)
        .frame(maxWidth: .infinity, minHeight: 150, alignment: .topLeading)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: CBRadius.large))
    }

    private var progressFraction: CGFloat {
        guard progress.total > 0 else { return 0 }
        return min(max(CGFloat(progress.done) / CGFloat(progress.total), 0), 1)
    }
}
