//
//  ManageSubscriptionVM.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 28.11.25.
//

import Foundation
import Combine

final class ManageSubscriptionVM: BaseViewModel {

    private let userUseCase: UserUseCase

    @Published private(set) var userProfile: UserProfile?
    @Published private(set) var currentPlan: CurrentPlanViewData?
    @Published private(set) var historyItems: [SubscriptionHistoryItemViewData] = []

    init(userUseCase: UserUseCase) {
        self.userUseCase = userUseCase
        super.init()
    }

    func getUserProfile() {
        performWithLoading(
            showAdForNonPremiumUser: false,
            operation: { [weak self] completion in
                guard let self else { return }
                self.userUseCase.fetchProfile { completion($0) }
            },
            errorMapper: { [weak self] (error: ProfileError) in
                guard let self else { return "Something went wrong. Please try again." }
                switch error {
                case .network(let rawMessage):
                    return self.decodeServerMessage(rawMessage)
                }
            },
            onSuccess: { [weak self] profile in
                guard let self else { return }
                self.userProfile = profile
                self.currentPlan = self.makeCurrentPlan(from: profile.data.user)
                self.getHistory()
            }
        )
    }

    private func getHistory() {
        performWithLoading(
            showAdForNonPremiumUser: false,
            operation: { [weak self] completion in
                guard let self else { return }
                self.userUseCase.fetchSubscriptionHistory { completion($0) }
            },
            errorMapper: { [weak self] (error: ProfileError) in
                guard let self else { return "Something went wrong. Please try again." }
                switch error {
                case .network(let rawMessage):
                    return self.decodeServerMessage(rawMessage)
                }
            },
            onSuccess: { [weak self] (history: SubscriptionHistory) in
                guard let self else { return }
                self.historyItems = self.mapHistory(history)
            }
        )
    }

    private func makeCurrentPlan(from user: User) -> CurrentPlanViewData {
        let title: String = {
            switch user.premiumPlan?.lowercased() {
            case "yearly":  return "You're on the Yearly Plan"
            case "monthly": return "You're on the Monthly Plan"
            default:        return "You're on the Premium Plan"
            }
        }()

        let subtitle: String? = {
            guard let raw = user.premiumExpiresAt, !raw.isEmpty else { return nil }
            let date = raw.toDisplayDate("d MMM yyyy")
            return date.isEmpty ? nil : "Renews on \(date)"
        }()

        return CurrentPlanViewData(title: title, subtitle: subtitle)
    }

    private func mapHistory(_ history: SubscriptionHistory) -> [SubscriptionHistoryItemViewData] {
        let events = history.data?.events ?? []

        func displayDate(from raw: String?) -> String {
            guard let raw, !raw.isEmpty else { return "" }
            let d = raw.toDisplayDate("d MMM yyyy")
            return d.isEmpty ? raw : d
        }

        return events.map { event in
            let planText: String = {
                switch event.plan?.lowercased() {
                case "yearly":  return "Yearly plan"
                case "monthly": return "Monthly plan"
                default:        return "Subscription"
                }
            }()

            let actionText: String = {
                if (event.isActive ?? false) == false { return "deactivated" }

                switch event.type {
                case "initial_purchase": return "started"
                case "renewal":         return "renewed"
                case "product_change":  return "changed"
                case "restore":         return "restored"
                default:                return "updated"
                }
            }()

            let title = "\(planText) \(actionText)"
            let dateText = displayDate(from: event.date)
            let statusText = (event.isActive ?? false) ? "Completed" : "Inactive"

            return SubscriptionHistoryItemViewData(
                title: title,
                dateText: dateText,
                statusText: statusText
            )
        }
    }
}
