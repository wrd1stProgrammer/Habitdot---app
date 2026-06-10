import Foundation
import Observation
import RevenueCat

@MainActor
@Observable
final class HabitdotPurchaseStore {
    var isLoadingOfferings = false
    var isPurchasing = false
    var isRestoring = false
    var isProUnlocked = false
    var priceTextByPlanID: [HabitdotProPlan.ID: String] = [:]
    var weeklyPriceTextByPlanID: [HabitdotProPlan.ID: String] = [:]
    var lastErrorMessage: String?

    @ObservationIgnored private var packagesByPlan: [HabitdotProPlan: Package] = [:]

    var canPurchase: Bool {
        RevenueCatConfig.hasValidPublicAPIKey
    }

    func configureIfPossible() -> Bool {
        guard RevenueCatConfig.hasValidPublicAPIKey else { return false }
        guard !Purchases.isConfigured else { return true }

        Purchases.logLevel = .warn
        let configuration = Configuration.Builder(withAPIKey: RevenueCatConfig.publicAPIKey)
            .with(storeKitVersion: .storeKit1)
            .build()
        Purchases.configure(with: configuration)
        return true
    }

    func loadPaywallData() async {
        guard configureIfPossible() else {
            lastErrorMessage = AppLocalization.localizedString("purchase.error.missingAPIKey")
            return
        }

        isLoadingOfferings = true
        defer { isLoadingOfferings = false }

        do {
            let offerings = try await Purchases.shared.offerings()
            let offering = offerings.current ?? offerings.all.values.first
            let packages = offering?.availablePackages ?? []
            applyPackages(packages)

            let customerInfo = try await Purchases.shared.customerInfo()
            applyCustomerInfo(customerInfo)
        } catch {
            lastErrorMessage = error.localizedDescription
        }
    }

    @discardableResult
    func refreshEntitlementStatus() async -> Bool {
        guard configureIfPossible() else { return isProUnlocked }

        do {
            let customerInfo = try await Purchases.shared.customerInfo()
            return applyCustomerInfo(customerInfo)
        } catch {
            return isProUnlocked
        }
    }

    @discardableResult
    func purchase(_ plan: HabitdotProPlan) async throws -> Bool {
        guard configureIfPossible() else {
            throw HabitdotPurchaseError.missingAPIKey
        }
        guard let package = packagesByPlan[plan] else {
            throw HabitdotPurchaseError.packageUnavailable
        }

        isPurchasing = true
        defer { isPurchasing = false }

        let result = try await Purchases.shared.purchase(package: package)
        guard !result.userCancelled else { return isProUnlocked }
        return applyCustomerInfo(result.customerInfo)
    }

    @discardableResult
    func restorePurchases() async throws -> Bool {
        guard configureIfPossible() else {
            throw HabitdotPurchaseError.missingAPIKey
        }

        isRestoring = true
        defer { isRestoring = false }

        let customerInfo = try await Purchases.shared.restorePurchases()
        return applyCustomerInfo(customerInfo)
    }

    func priceText(for plan: HabitdotProPlan) -> String? {
        priceTextByPlanID[plan.id]
    }

    func weeklyPriceText(for plan: HabitdotProPlan) -> String? {
        weeklyPriceTextByPlanID[plan.id]
    }

    func clearError() {
        lastErrorMessage = nil
    }

    private func applyPackages(_ packages: [Package]) {
        packagesByPlan.removeAll()
        priceTextByPlanID.removeAll()
        weeklyPriceTextByPlanID.removeAll()

        for package in packages {
            guard let plan = plan(for: package) else { continue }
            packagesByPlan[plan] = package
            priceTextByPlanID[plan.id] = package.localizedPriceString
            weeklyPriceTextByPlanID[plan.id] = weeklyPriceText(for: package, plan: plan)
        }
    }

    @discardableResult
    private func applyCustomerInfo(_ customerInfo: CustomerInfo) -> Bool {
        let unlocked = customerInfo.entitlements[RevenueCatConfig.proEntitlementID]?.isActive == true
        isProUnlocked = unlocked
        return unlocked
    }

    private func plan(for package: Package) -> HabitdotProPlan? {
        if let plan = HabitdotProPlan.allCases.first(where: { $0.productIdentifier == package.storeProduct.productIdentifier }) {
            return plan
        }

        switch package.packageType {
        case .annual:
            return .annual
        case .monthly:
            return .monthly
        case .lifetime:
            return .lifetime
        default:
            return nil
        }
    }

    private func weeklyPriceText(for package: Package, plan: HabitdotProPlan) -> String? {
        let weekDivisor: Double
        switch plan {
        case .annual:
            weekDivisor = 52
        case .monthly:
            weekDivisor = 4
        case .lifetime:
            return nil
        }

        let weeklyPrice = NSDecimalNumber(decimal: package.storeProduct.price)
            .dividing(by: NSDecimalNumber(value: weekDivisor))
        guard let formattedPrice = priceFormatter(for: package).string(from: weeklyPrice) else { return nil }
        return String(format: AppLocalization.localizedString("paywall.plan.perWeek"), formattedPrice)
    }

    private func priceFormatter(for package: Package) -> NumberFormatter {
        if let formatter = package.storeProduct.priceFormatter {
            formatter.maximumFractionDigits = 0
            return formatter
        }

        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        if let currencyCode = package.storeProduct.currencyCode {
            formatter.currencyCode = currencyCode
        }
        formatter.maximumFractionDigits = 0
        return formatter
    }
}

private enum HabitdotPurchaseError: LocalizedError {
    case missingAPIKey
    case packageUnavailable

    var errorDescription: String? {
        switch self {
        case .missingAPIKey:
            AppLocalization.localizedString("purchase.error.missingAPIKey")
        case .packageUnavailable:
            AppLocalization.localizedString("purchase.error.packageUnavailable")
        }
    }
}
