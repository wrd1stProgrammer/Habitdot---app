import Foundation
import Observation
import WidgetKit

@MainActor
@Observable
final class HabitStore {
    var snapshot: HabitSnapshot
    var selectedDate: Date
    var selectedTab: HabitdotTab
    var gridPeriod: HabitGridPeriod
    var gridReferenceDate: Date
    var gridDisplayMode: GridDisplayMode
    var feedbackTrigger: Int
    var dailyMotivationText: String?
    var dailyMotivationIsLoading: Bool
    var dailyMotivationProvider: String?
    private var dailyMotivationRequestKey: String?
    private let motivationService: HabitMotivationService

    init(snapshot: HabitSnapshot = HabitdotStorage.load()) {
        self.snapshot = snapshot
        self.selectedDate = Date()
        self.selectedTab = .today
        self.gridPeriod = .weekly
        self.gridReferenceDate = Date()
        self.gridDisplayMode = .dots
        self.feedbackTrigger = 0
        self.dailyMotivationText = nil
        self.dailyMotivationIsLoading = false
        self.dailyMotivationProvider = nil
        self.dailyMotivationRequestKey = nil
        self.motivationService = HabitMotivationService()
        HabitdotSyncNotification.addSnapshotObserver(
            Unmanaged.passUnretained(self).toOpaque(),
            callback: habitdotSnapshotDidChangeCallback
        )
    }

    var activeHabits: [Habit] {
        snapshot.activeHabits
    }

    var accessibleActiveHabits: [Habit] {
        snapshot.accessibleActiveHabits
    }

    var isProUnlocked: Bool {
        snapshot.settings.isProUnlocked
    }

    var canCreateHabit: Bool {
        isProUnlocked || activeHabits.count < 3
    }

    var archivedHabits: [Habit] {
        snapshot.archivedHabits
    }

    func finishOnboarding(_ payload: OnboardingCompletionPayload) {
        let preferredHabitKey = payload.preferredHabitKey
        let preferredAppearanceID = payload.preferredAppearanceID
        let commonReminderTime = payload.commonReminderTime

        if let preferredAppearanceID, let appearance = HabitAppearance(rawValue: preferredAppearanceID) {
            snapshot.settings.appearance = appearance
        }

        snapshot.settings.commonReminderHour = commonReminderTime?.hour
        snapshot.settings.commonReminderMinute = commonReminderTime?.minute
        snapshot.settings.onboardingSource = payload.source
        snapshot.settings.onboardingSurvey = payload.selections
        snapshot.settings.onboardingCountryCode = payload.countryCode
        snapshot.settings.onboardingLocaleIdentifier = payload.localeIdentifier
        snapshot.settings.onboardingCompletedAt = payload.completedAt

        if
            let preferredHabitKey,
            let habit = onboardingHabit(
                for: preferredHabitKey,
                customTitle: payload.customHabitTitle,
                order: nextDisplayOrder()
            ),
            !snapshot.habits.contains(where: { !$0.isArchived && $0.title == habit.title })
        {
            snapshot.habits.append(habit)
        }

        snapshot.updatedAt = Date()
        persist()

        submitOnboardingPayload(payload)
    }

    func addHabit(
        title: String,
        purpose: String?,
        colorToken: HabitColorToken,
        frequency: HabitFrequency,
        reminderHour: Int?,
        reminderMinute: Int?,
        targetCount: Int = 1
    ) {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPurpose = purpose?.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else { return }

        let habit = Habit(
            title: trimmedTitle,
            purpose: trimmedPurpose?.isEmpty == false ? trimmedPurpose : nil,
            symbolName: "checkmark",
            colorToken: colorToken,
            frequency: frequency,
            targetCount: targetCount,
            reminderHour: reminderHour,
            reminderMinute: reminderHour == nil ? nil : reminderMinute ?? 0,
            displayOrder: nextDisplayOrder()
        )
        snapshot.habits.append(habit)
        persist()
    }

    func updateHabitDetails(
        _ habit: Habit,
        title: String,
        purpose: String?,
        colorToken: HabitColorToken,
        frequency: HabitFrequency,
        reminderHour: Int?,
        reminderMinute: Int?,
        targetCount: Int
    ) {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPurpose = purpose?.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else { return }

        updateHabit(habit) { editableHabit in
            editableHabit.title = trimmedTitle
            editableHabit.purpose = trimmedPurpose?.isEmpty == false ? trimmedPurpose : nil
            editableHabit.colorToken = colorToken
            editableHabit.frequency = frequency
            editableHabit.targetCount = max(1, targetCount)
            editableHabit.reminderHour = reminderHour
            editableHabit.reminderMinute = reminderHour == nil ? nil : reminderMinute ?? 0
        }
    }

    func toggle(_ habit: Habit, on date: Date) {
        snapshot.toggleCompletion(for: habit.id, dayKey: HabitDate.dayKey(date))
        triggerFeedback()
        persist()
    }

    func setAppearance(_ appearance: HabitAppearance) {
        snapshot.settings.appearance = appearance
        persist()
    }

    func setFirstWeekday(_ weekday: Int) {
        snapshot.settings.firstWeekday = min(max(weekday, 1), 7)
        persist()
    }

    func setProUnlocked(_ isUnlocked: Bool) {
        guard snapshot.settings.isProUnlocked != isUnlocked else { return }
        snapshot.settings.isProUnlocked = isUnlocked
        persist()
    }

    func archive(_ habit: Habit) {
        updateHabit(habit) { $0.isArchived = true }
    }

    func restore(_ habit: Habit) {
        updateHabit(habit) { $0.isArchived = false }
    }

    func toggleReminder(for habit: Habit) {
        updateHabit(habit) { editableHabit in
            if editableHabit.reminderHour == nil {
                editableHabit.reminderHour = 9
                editableHabit.reminderMinute = 0
            } else {
                editableHabit.reminderHour = nil
                editableHabit.reminderMinute = nil
            }
        }
    }

    func setCommonReminder(enabled: Bool, hour: Int, minute: Int) {
        snapshot.settings.commonReminderHour = enabled ? min(max(hour, 0), 23) : nil
        snapshot.settings.commonReminderMinute = enabled ? min(max(minute, 0), 59) : nil
        persist()
    }

    func setReminder(for habit: Habit, enabled: Bool, hour: Int, minute: Int) {
        updateHabit(habit) { editableHabit in
            editableHabit.reminderHour = enabled ? min(max(hour, 0), 23) : nil
            editableHabit.reminderMinute = enabled ? min(max(minute, 0), 59) : nil
        }
    }

    func rescheduleReminders() {
        HabitReminderScheduler.sync(snapshot: snapshot)
    }

    func moveHabit(from source: IndexSet, to destination: Int) {
        var habits = activeHabits
        habits.move(fromOffsets: source, toOffset: destination)
        for (index, habit) in habits.enumerated() {
            updateHabit(habit, shouldPersist: false) { $0.displayOrder = index }
        }
        persist()
    }

    func moveHabit(_ movingHabit: Habit, to targetHabit: Habit) {
        var habits = activeHabits
        guard
            let sourceIndex = habits.firstIndex(where: { $0.id == movingHabit.id }),
            let targetIndex = habits.firstIndex(where: { $0.id == targetHabit.id }),
            sourceIndex != targetIndex
        else { return }

        habits.move(fromOffsets: IndexSet(integer: sourceIndex), toOffset: targetIndex > sourceIndex ? targetIndex + 1 : targetIndex)
        for (index, habit) in habits.enumerated() {
            updateHabit(habit, shouldPersist: false) { $0.displayOrder = index }
        }
        persist()
        triggerFeedback()
    }

    func completionCount(for habit: Habit, on date: Date) -> Int {
        snapshot.count(for: habit.id, dayKey: HabitDate.dayKey(date))
    }

    func isComplete(_ habit: Habit, on date: Date) -> Bool {
        snapshot.isComplete(habit, dayKey: HabitDate.dayKey(date))
    }

    func streak(for habit: Habit, endingAt date: Date = Date()) -> Int {
        var calendar = Calendar.current
        calendar.firstWeekday = snapshot.settings.firstWeekday
        var cursor = calendar.startOfDay(for: date)
        var streak = 0

        while snapshot.isComplete(habit, dayKey: HabitDate.dayKey(cursor, calendar: calendar)) {
            streak += 1
            guard let previous = calendar.date(byAdding: .day, value: -1, to: cursor) else { break }
            cursor = previous
        }

        return streak
    }

    func weeklyCompletionCount(for habit: Habit, containing date: Date) -> Int {
        var calendar = Calendar.current
        calendar.firstWeekday = snapshot.settings.firstWeekday
        return HabitDate.daysInWeek(containing: date, calendar: calendar)
            .filter { snapshot.isComplete(habit, dayKey: HabitDate.dayKey($0, calendar: calendar)) }
            .count
    }

    var dailyMotivationRefreshToken: String {
        dailyMotivationRequest?.cacheIdentity ?? "empty|\(motivationLocale)|\(HabitDate.dayKey(selectedDate))"
    }

    func refreshDailyMotivationIfNeeded() async {
        guard isProUnlocked else {
            dailyMotivationText = nil
            dailyMotivationProvider = nil
            dailyMotivationRequestKey = nil
            return
        }

        guard let request = dailyMotivationRequest else {
            dailyMotivationText = nil
            dailyMotivationProvider = nil
            dailyMotivationRequestKey = nil
            return
        }

        if let cachedResponse = motivationService.cachedResponse(for: request) {
            applyMotivation(cachedResponse, requestKey: request.cacheIdentity)
            return
        }

        if dailyMotivationRequestKey != request.cacheIdentity {
            dailyMotivationText = nil
            dailyMotivationProvider = nil
        }

        guard !dailyMotivationIsLoading else { return }
        dailyMotivationIsLoading = true
        defer { dailyMotivationIsLoading = false }

        do {
            let response = try await motivationService.fetchResponse(for: request)
            applyMotivation(response, requestKey: request.cacheIdentity)
        } catch {
            dailyMotivationText = nil
            dailyMotivationProvider = nil
            dailyMotivationRequestKey = nil
        }
    }

    func progressDates(for period: HabitGridPeriod, around date: Date) -> [Date] {
        var calendar = Calendar.current
        calendar.firstWeekday = snapshot.settings.firstWeekday
        switch period {
        case .weekly:
            return HabitDate.daysEndingToday(date, count: 7, calendar: calendar)
        case .monthly:
            return HabitDate.daysInMonth(containing: date, calendar: calendar)
        case .quarterly:
            return HabitDate.daysInQuarter(containing: date, calendar: calendar)
        }
    }

    func stepGridDate(_ direction: Int) {
        var calendar = Calendar.current
        calendar.firstWeekday = snapshot.settings.firstWeekday
        let component: Calendar.Component = switch gridPeriod {
        case .weekly: .weekOfYear
        case .monthly: .month
        case .quarterly: .month
        }
        let value = gridPeriod == .quarterly ? direction * 3 : direction
        gridReferenceDate = calendar.date(byAdding: component, value: value, to: gridReferenceDate) ?? gridReferenceDate
        triggerFeedback()
    }

    func triggerFeedback() {
        feedbackTrigger += 1
    }

    func refreshForCurrentLocalDayIfNeeded() {
        let now = Date()
        guard HabitDate.dayKey(selectedDate) != HabitDate.dayKey(now) else { return }
        selectedDate = now
        dailyMotivationText = nil
        dailyMotivationProvider = nil
        dailyMotivationRequestKey = nil
    }

    func reloadSnapshotFromSharedStorageIfNeeded() {
        let latestSnapshot = HabitdotStorage.load()
        guard latestSnapshot != snapshot else { return }
        snapshot = latestSnapshot
        triggerFeedback()
    }

    func exportJSON() -> String {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        guard let data = try? encoder.encode(snapshot) else { return "{}" }
        return String(decoding: data, as: UTF8.self)
    }

    func importJSON(_ text: String) -> Bool {
        guard let data = text.data(using: .utf8) else { return false }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        guard let importedSnapshot = try? decoder.decode(HabitSnapshot.self, from: data) else { return false }
        snapshot = importedSnapshot
        persist()
        return true
    }

    private func addSeedHabits(preferredHabitKey: String?) {
        var seeds = defaultSeedHabits()
        if let preferredHabitKey, let preferred = seedHabit(for: preferredHabitKey, order: 0) {
            seeds.removeAll { $0.title == preferred.title }
            seeds.insert(preferred, at: 0)
            for index in seeds.indices {
                seeds[index].displayOrder = index
            }
        }
        snapshot.habits.append(contentsOf: seeds)
        let todayKey = HabitDate.dayKey(Date())
        snapshot.setCount(1, for: seeds[0].id, dayKey: todayKey)
        if seeds.indices.contains(2) {
            snapshot.setCount(1, for: seeds[2].id, dayKey: todayKey)
        }
        persist()
    }

    private func defaultSeedHabits() -> [Habit] {
        [
            Habit(title: AppLocalization.localizedString("habit.seed.walk"), symbolName: "figure.walk", colorToken: .amber, frequency: .timesPerWeek(6), displayOrder: 0),
            Habit(title: AppLocalization.localizedString("habit.seed.water"), symbolName: "drop", colorToken: .rose, frequency: .everyday, targetCount: 2, displayOrder: 1),
            Habit(title: AppLocalization.localizedString("habit.seed.read"), symbolName: "book", colorToken: .indigo, frequency: .everyday, displayOrder: 2)
        ]
    }

    private func seedHabit(for key: String, order: Int) -> Habit? {
        switch key {
        case "onboarding.habit.walk":
            Habit(title: AppLocalization.localizedString("habit.seed.walk"), symbolName: "figure.walk", colorToken: .amber, frequency: .timesPerWeek(6), displayOrder: order)
        case "onboarding.habit.water":
            Habit(title: AppLocalization.localizedString("habit.seed.water"), symbolName: "drop", colorToken: .rose, frequency: .everyday, targetCount: 2, displayOrder: order)
        case "onboarding.habit.read":
            Habit(title: AppLocalization.localizedString("habit.seed.read"), symbolName: "book", colorToken: .indigo, frequency: .everyday, displayOrder: order)
        case "onboarding.habit.exercise":
            Habit(title: AppLocalization.localizedString("habit.seed.exercise"), symbolName: "dumbbell", colorToken: .violet, frequency: .timesPerWeek(5), displayOrder: order)
        case "onboarding.habit.sleep":
            Habit(title: AppLocalization.localizedString("habit.seed.sleep"), symbolName: "moon", colorToken: .blue, frequency: .everyday, displayOrder: order)
        default:
            nil
        }
    }

    private func onboardingHabit(for key: String, customTitle: String?, order: Int) -> Habit? {
        if key == OnboardingHabitSelection.customID {
            guard
                let title = customTitle?.trimmingCharacters(in: .whitespacesAndNewlines),
                !title.isEmpty
            else {
                return nil
            }

            return Habit(
                title: title,
                symbolName: "checkmark",
                colorToken: .indigo,
                frequency: .everyday,
                displayOrder: order
            )
        }

        return seedHabit(for: key, order: order)
    }

    private func updateHabit(_ habit: Habit, shouldPersist: Bool = true, mutation: (inout Habit) -> Void) {
        guard let index = snapshot.habits.firstIndex(where: { $0.id == habit.id }) else { return }
        mutation(&snapshot.habits[index])
        snapshot.updatedAt = Date()
        if shouldPersist {
            persist()
        }
    }

    private var dailyMotivationRequest: HabitMotivationRequest? {
        guard isProUnlocked else { return nil }

        let habits = activeHabits.prefix(10).map { habit in
            HabitMotivationHabitPayload(
                title: String(habit.title.prefix(60)),
                purpose: habit.purpose.map { String($0.prefix(160)) },
                colorHex: String(format: "#%06X", habit.colorToken.hex),
                completedToday: isComplete(habit, on: selectedDate),
                completedYesterday: isComplete(habit, on: yesterday(for: selectedDate)),
                currentStreak: streak(for: habit, endingAt: selectedDate),
                weeklyCompletionCount: weeklyCompletionCount(for: habit, containing: selectedDate),
                recent7Days: recentSevenDayPayloads(for: habit, endingAt: selectedDate)
            )
        }

        guard !habits.isEmpty else { return nil }

        return HabitMotivationRequest(
            locale: motivationLocale,
            date: HabitDate.dayKey(selectedDate),
            habits: habits
        )
    }

    private var motivationLocale: String {
        let rawValue = UserDefaults.standard.string(forKey: AppLanguage.storageKey) ?? AppLanguage.englishUS.rawValue
        let language = AppLanguage.selected(from: rawValue)

        switch language {
        case .system:
            return motivationLocaleIdentifier(for: Locale.autoupdatingCurrent.identifier)
        default:
            return language.locale.identifier
        }
    }

    private func motivationLocaleIdentifier(for identifier: String) -> String {
        let lowercasedIdentifier = identifier.lowercased()
        if lowercasedIdentifier.hasPrefix("ko") { return "ko" }
        if lowercasedIdentifier.hasPrefix("ja") { return "ja" }
        if lowercasedIdentifier.hasPrefix("de") { return "de" }
        if lowercasedIdentifier.hasPrefix("fr") { return "fr-FR" }
        if lowercasedIdentifier.hasPrefix("th") { return "th" }
        if lowercasedIdentifier.hasPrefix("zh-hant") || lowercasedIdentifier.hasPrefix("zh-tw") || lowercasedIdentifier.hasPrefix("zh-hk") {
            return "zh-Hant"
        }
        if lowercasedIdentifier.hasPrefix("zh") { return "zh-Hans" }
        if lowercasedIdentifier.hasPrefix("en-gb") { return "en-GB" }
        if lowercasedIdentifier.hasPrefix("en-ca") { return "en-CA" }
        return "en-US"
    }

    private func applyMotivation(_ response: HabitMotivationResponse, requestKey: String) {
        let trimmedText = displaySafeMotivation(response.text)
        dailyMotivationText = trimmedText.isEmpty ? nil : trimmedText
        dailyMotivationProvider = response.provider
        dailyMotivationRequestKey = requestKey
    }

    private func displaySafeMotivation(_ text: String) -> String {
        let plainText = motivationPlainText(from: text)
        let normalizedText = plainText
            .replacingOccurrences(of: "\n", with: " ")
            .replacingOccurrences(of: "\t", with: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        let collapsedText = normalizedText
            .split(whereSeparator: \.isWhitespace)
            .joined(separator: " ")
        let limit = motivationLocale == "ko" ? 32 : 70
        guard collapsedText.count > limit else { return collapsedText }
        return String(collapsedText.prefix(limit)).trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func motivationPlainText(from text: String) -> String {
        var candidate = text.trimmingCharacters(in: .whitespacesAndNewlines)

        if
            let data = candidate.data(using: .utf8),
            let object = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
            let value = object["text"] as? String
        {
            candidate = value
        } else {
            let lowercasedCandidate = candidate.lowercased()
            if lowercasedCandidate.hasPrefix("{text:") {
                candidate = String(candidate.dropFirst(6))
            } else if lowercasedCandidate.hasPrefix("{\"text\":") {
                candidate = String(candidate.dropFirst(8))
            } else if lowercasedCandidate.hasPrefix("text:") {
                candidate = String(candidate.dropFirst(5))
            }

            if candidate.hasSuffix("}") {
                candidate.removeLast()
            }
        }

        return candidate
            .trimmingCharacters(in: CharacterSet.whitespacesAndNewlines.union(CharacterSet(charactersIn: "\"'“”‘’「」『』{}")))
            .replacingOccurrences(of: "\\\"", with: "\"")
    }

    private func submitOnboardingPayload(_ payload: OnboardingCompletionPayload) {
        let request = HabitdotOnboardingSubmissionRequest(
            locale: payload.localeIdentifier,
            countryCode: payload.countryCode,
            timeZone: payload.timeZoneIdentifier,
            appVersion: payload.appVersion,
            buildNumber: payload.buildNumber,
            platform: "ios",
            completedAt: payload.completedAt,
            source: payload.source,
            selectedFirstHabit: payload.preferredHabitKey,
            selectedTheme: payload.preferredAppearanceID,
            commonReminderHour: payload.commonReminderTime?.hour,
            commonReminderMinute: payload.commonReminderTime?.minute,
            survey: payload.selections
        )

        Task {
            try? await HabitdotOnboardingSubmissionService().submit(request)
        }
    }

    private func recentSevenDayPayloads(for habit: Habit, endingAt date: Date) -> [HabitMotivationDayPayload] {
        var calendar = Calendar.current
        calendar.firstWeekday = snapshot.settings.firstWeekday
        return HabitDate.daysEndingToday(date, count: 7, calendar: calendar).map { day in
            let dayKey = HabitDate.dayKey(day, calendar: calendar)
            let count = snapshot.count(for: habit.id, dayKey: dayKey)
            return HabitMotivationDayPayload(
                date: dayKey,
                completed: count >= habit.targetCount,
                count: count
            )
        }
    }

    private func yesterday(for date: Date) -> Date {
        Calendar.current.date(byAdding: .day, value: -1, to: date) ?? date
    }

    private func nextDisplayOrder() -> Int {
        (snapshot.habits.map(\.displayOrder).max() ?? -1) + 1
    }

    private func persist() {
        HabitdotStorage.save(snapshot)
        HabitReminderScheduler.sync(snapshot: snapshot)
        for widgetKind in HabitdotWidgetKind.all {
            WidgetCenter.shared.reloadTimelines(ofKind: widgetKind)
        }
        WidgetCenter.shared.reloadAllTimelines()
    }
}

private func habitdotSnapshotDidChangeCallback(
    center: CFNotificationCenter?,
    observer: UnsafeMutableRawPointer?,
    name: CFNotificationName?,
    object: UnsafeRawPointer?,
    userInfo: CFDictionary?
) {
    guard let observer else { return }
    let observerAddress = UInt(bitPattern: observer)

    Task { @MainActor in
        guard let observer = UnsafeMutableRawPointer(bitPattern: observerAddress) else { return }
        let store = Unmanaged<HabitStore>.fromOpaque(observer).takeUnretainedValue()
        store.reloadSnapshotFromSharedStorageIfNeeded()
    }
}
