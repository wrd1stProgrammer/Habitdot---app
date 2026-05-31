import SwiftUI

enum SettingsFeedbackKind: String, Identifiable {
    case feedback
    case contact
    case bug

    var id: String { rawValue }

    var titleKey: LocalizedStringKey {
        switch self {
        case .feedback: "settings.feedback"
        case .contact: "settings.contact"
        case .bug: "settings.bug"
        }
    }

    var subject: String {
        switch self {
        case .feedback:
            AppLocalization.localizedString("settings.feedback.mailSubject")
        case .contact:
            AppLocalization.localizedString("settings.contact.mailSubject")
        case .bug:
            AppLocalization.localizedString("settings.bug.mailSubject")
        }
    }

    var placeholderKey: LocalizedStringKey {
        switch self {
        case .feedback: "settings.feedback.placeholder"
        case .contact: "settings.contact.placeholder"
        case .bug: "settings.bug.placeholder"
        }
    }
}

struct FeedbackComposeView: View {
    @Environment(\.dismiss) private var dismiss
    let kind: SettingsFeedbackKind
    private let feedbackService: FeedbackSubmissionService
    @State private var message = ""
    @State private var isSubmitting = false
    @State private var isSubmitErrorPresented = false

    init(kind: SettingsFeedbackKind, feedbackService: FeedbackSubmissionService = FeedbackSubmissionService()) {
        self.kind = kind
        self.feedbackService = feedbackService
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 14) {
                ZStack(alignment: .topLeading) {
                    TextEditor(text: $message)
                        .font(.system(size: 16, weight: .medium))
                        .scrollContentBackground(.hidden)
                        .padding(12)
                        .frame(minHeight: 220)
                        .background(Color.habitdotCard, in: RoundedRectangle(cornerRadius: 20, style: .continuous))

                    if message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        Text(kind.placeholderKey)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(Color.habitdotSecondaryText)
                            .padding(.horizontal, 18)
                            .padding(.vertical, 20)
                            .allowsHitTesting(false)
                    }
                }

                Text("settings.feedback.submitNotice")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color.habitdotSecondaryText)

                Spacer()
            }
            .padding(16)
            .background(Color.habitdotBackground.ignoresSafeArea())
            .navigationTitle(kind.titleKey)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("common.cancel", action: { dismiss() })
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(action: send) {
                        if isSubmitting {
                            ProgressView()
                        } else {
                            Text("settings.feedback.send")
                        }
                    }
                    .fontWeight(.semibold)
                    .disabled(message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isSubmitting)
                }
            }
            .alert("settings.feedback.submitError.title", isPresented: $isSubmitErrorPresented) {
                Button("common.ok", role: .cancel) {}
            } message: {
                Text("settings.feedback.submitError.body")
            }
        }
    }

    private func send() {
        let trimmedMessage = message.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedMessage.isEmpty, !isSubmitting else { return }

        isSubmitting = true
        Task {
            do {
                try await feedbackService.submit(submissionRequest(message: trimmedMessage))
                dismiss()
            } catch {
                isSubmitErrorPresented = true
            }
            isSubmitting = false
        }
    }

    private func submissionRequest(message: String) -> FeedbackSubmissionRequest {
        FeedbackSubmissionRequest(
            kind: kind.rawValue,
            subject: kind.subject,
            message: message,
            locale: Locale.autoupdatingCurrent.identifier,
            countryCode: Locale.autoupdatingCurrent.habitdotCountryCode,
            timeZone: TimeZone.autoupdatingCurrent.identifier,
            appVersion: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "-",
            buildNumber: Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "-",
            platform: "ios"
        )
    }
}
