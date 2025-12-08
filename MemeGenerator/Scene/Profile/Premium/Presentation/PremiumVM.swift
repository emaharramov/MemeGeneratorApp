//
//  PremiumVM.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 28.11.25.
//

import Foundation
import RevenueCat

final class PremiumVM: BaseViewModel {

    enum Plan {
        case yearly
        case monthly

        var productId: String {
            switch self {
            case .yearly:  return "yearly"
            case .monthly: return "monthly"
            }
        }
    }

    private let userId: String
    private let repository: PremiumRepository

    var onPremiumActivated: (() -> Void)?
    var onShowMessage: ((String) -> Void)?
    var onLoadingChange: ((Bool) -> Void)?

    init(userId: String, repository: PremiumRepository) {
        self.userId = userId
        self.repository = repository
    }

    func upgrade(with plan: Plan) {
        onLoadingChange?(true)

        Purchases.shared.getOfferings { [weak self] offerings, error in
            guard let self else { return }

            if let error {
                self.onLoadingChange?(false)
                self.onShowMessage?(error.localizedDescription)
                return
            }

            guard
                let packages = offerings?.current?.availablePackages,
                let package = packages.first(where: { $0.storeProduct.productIdentifier == plan.productId })
            else {
                self.onLoadingChange?(false)
                self.onShowMessage?("No subscription package found.")
                return
            }

            Purchases.shared.purchase(package: package) { [weak self] _, customerInfo, error, userCancelled in
                guard let self else { return }

                if userCancelled == true {
                    self.onLoadingChange?(false)
                    return
                }

                if let error {
                    self.onLoadingChange?(false)
                    self.onShowMessage?(error.localizedDescription)
                    return
                }

                guard
                    let info = customerInfo,
                    let entitlement = info.entitlements.all["MemeCraft Pro"],
                    entitlement.isActive
                else {
                    self.onLoadingChange?(false)
                    self.onShowMessage?("Purchase did not activate premium.")
                    return
                }

                let expiresAtISO: String?
                if let exp = entitlement.expirationDate {
                    let formatter = ISO8601DateFormatter()
                    formatter.formatOptions = [.withInternetDateTime]
                    expiresAtISO = formatter.string(from: exp)
                } else {
                    expiresAtISO = nil
                }

                let req = SyncPremiumRequestDTO(
                    userId: self.userId,
                    entitlementId: "MemeCraft Pro",
                    productId: package.storeProduct.productIdentifier,
                    isActive: true,
                    expiresAt: expiresAtISO
                )

                self.repository.syncPremium(request: req) { [weak self] result in
                    guard let self else { return }
                    self.onLoadingChange?(false)

                    switch result {
                    case .success:
                        self.onPremiumActivated?()
                    case .failure(let error):
                        self.onShowMessage?(error.localizedDescription)
                    }
                }
            }
        }
    }

    func restore() {
        onLoadingChange?(true)

        Purchases.shared.restorePurchases { [weak self] customerInfo, error in
            guard let self else { return }

            if let error {
                self.onLoadingChange?(false)
                self.onShowMessage?(error.localizedDescription)
                return
            }

            guard
                let info = customerInfo,
                let entitlement = info.entitlements.all["MemeCraft Pro"],
                entitlement.isActive
            else {
                self.onLoadingChange?(false)
                self.onShowMessage?("Purchase did not activate premium.")
                return
            }

            let expiresAtISO: String?
            if let exp = entitlement.expirationDate {
                let formatter = ISO8601DateFormatter()
                formatter.formatOptions = [.withInternetDateTime]
                expiresAtISO = formatter.string(from: exp)
            } else {
                expiresAtISO = nil
            }

            let productId = entitlement.productIdentifier

            let req = SyncPremiumRequestDTO(
                userId: self.userId,
                entitlementId: "MemeCraft Pro",
                productId: productId,
                isActive: true,
                expiresAt: expiresAtISO
            )

            self.repository.syncPremium(request: req) { [weak self] result in
                guard let self else { return }
                self.onLoadingChange?(false)

                switch result {
                case .success:
                    self.onPremiumActivated?()
                case .failure(let error):
                    self.onShowMessage?(error.localizedDescription)
                }
            }
        }
    }
}
