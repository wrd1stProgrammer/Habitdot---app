import SwiftUI

struct LegalDocumentView: View {
    let document: LegalDocument

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 22) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(document.title)
                        .font(.largeTitle.weight(.bold))
                        .foregroundStyle(Color.habitdotInk)

                    Text(document.effectiveDate)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.habitdotSecondaryText)
                }

                ForEach(document.sections) { section in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(section.title)
                            .font(.title3.weight(.bold))
                            .foregroundStyle(Color.habitdotInk)

                        Text(section.body)
                            .font(.body)
                            .lineSpacing(4)
                            .foregroundStyle(Color.habitdotSecondaryText)
                            .textSelection(.enabled)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 22)
            .padding(.bottom, 36)
        }
    }
}

struct LegalDocument {
    let titleKey: String
    let effectiveDateKey: String
    let sectionKeys: [LegalSectionKeys]

    var title: String {
        AppLocalization.localizedString(titleKey)
    }

    var effectiveDate: String {
        AppLocalization.localizedString(effectiveDateKey)
    }

    var sections: [LegalSection] {
        sectionKeys.map { keys in
            LegalSection(
                id: keys.id,
                title: AppLocalization.localizedString(keys.titleKey),
                body: AppLocalization.localizedString(keys.bodyKey)
            )
        }
    }

    static let privacyPolicy = LegalDocument(
        titleKey: "legal.privacy.title",
        effectiveDateKey: "legal.effectiveDate",
        sectionKeys: LegalSectionKeys.keys(prefix: "legal.privacy", count: 13)
    )

    static let termsOfUse = LegalDocument(
        titleKey: "legal.terms.title",
        effectiveDateKey: "legal.effectiveDate",
        sectionKeys: LegalSectionKeys.keys(prefix: "legal.terms", count: 15)
    )
}

struct LegalSection: Identifiable {
    let id: String
    let title: String
    let body: String
}

struct LegalSectionKeys {
    let id: String
    let titleKey: String
    let bodyKey: String

    static func keys(prefix: String, count: Int) -> [LegalSectionKeys] {
        (1...count).map { index in
            LegalSectionKeys(
                id: "\(prefix).section.\(index)",
                titleKey: "\(prefix).section.\(index).title",
                bodyKey: "\(prefix).section.\(index).body"
            )
        }
    }
}
