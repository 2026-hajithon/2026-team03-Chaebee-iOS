import SwiftUI

struct ProfileLegalDocumentView: View {
    let document: ProfileLegalDocument

    var body: some View {
        ScrollView {
            Text(document.body)
                .cbTypography(.body4)
                .foregroundStyle(CBColor.gray7)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(CBSpacing.pageHorizontal)
        }
        .background(CBColor.gray1)
        .navigationTitle(document.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

enum ProfileLegalDocument {
    case terms
    case privacy

    var title: LocalizedStringResource {
        switch self {
        case .terms: "profile.terms"
        case .privacy: "profile.privacy"
        }
    }

    var body: LocalizedStringResource {
        switch self {
        case .terms: "profile.terms.placeholder"
        case .privacy: "profile.privacy.placeholder"
        }
    }
}
