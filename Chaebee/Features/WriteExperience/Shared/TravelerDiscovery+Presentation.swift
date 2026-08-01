import SwiftUI

extension ExperienceAvatar {
    var imageResource: ImageResource {
        switch self {
        case .blue: .profileBlue
        case .green: .profileGreen
        case .indigo: .profileIndigo
        case .orange: .profileOrange
        case .red: .profileRed
        case .yellow: .profileYellow
        }
    }
}

extension ExperienceCountry {
    var localizedName: LocalizedStringResource {
        switch self {
        case .au: "country.au"
        case .br: "country.br"
        case .de: "country.de"
        case .fr: "country.fr"
        case .hk: "country.hk"
        case .jp: "country.jp"
        case .sg: "country.sg"
        case .th: "country.th"
        case .tw: "country.tw"
        case .uk: "country.uk"
        case .us: "country.us"
        case .vn: "country.vn"
        }
    }

    var flagResource: ImageResource {
        switch self {
        case .au: .flagAU
        case .br: .flagBR
        case .de: .flagDE
        case .fr: .flagFR
        case .hk: .flagHK
        case .jp: .flagJP
        case .sg: .flagSG
        case .th: .flagTH
        case .tw: .flagTW
        case .uk: .flagUK
        case .us: .flagUS
        case .vn: .flagVN
        }
    }
}
