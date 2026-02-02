//
//  SubscriptionManager.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 02.02.26.
//

import Foundation
import RevenueCat
import Combine

final class SubscriptionManager: ObservableObject {

    static let shared = SubscriptionManager()
    private init() {}

    private static let premiumEntitlementID = "MemeCraft Pro"

    @Published private(set) var isPremium: Bool = false

    func configureUserIfNeeded() {
        let userId = AppStorage.shared.userId
        guard !userId.isEmpty else { return }

        Purchases.shared.logIn(userId) { [weak self] _, _, _ in
            self?.refreshStatus()
        }
    }

    func refreshStatus() {
        Purchases.shared.getCustomerInfo { [weak self] info, _ in
            guard let self = self else { return }
            let active = info?.entitlements[Self.premiumEntitlementID]?.isActive == true
            DispatchQueue.main.async {
                self.isPremium = active
            }
        }
    }

    func logOut() {
        Purchases.shared.logOut { _, _ in }
        DispatchQueue.main.async {
            self.isPremium = false
        }
    }
}
