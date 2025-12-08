//
//  ManageSubscriptionVM.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 28.11.25.
//

import Foundation
import Combine

struct SubscriptionHistoryItemViewData {
    let title: String
    let dateText: String
    let statusText: String
}

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
            operation: { [weak self] completion in
                guard let self else { return }
                self.userUseCase.fetchProfile { result in
                    completion(result)
                }
            },
            errorMapper: { [weak self] (error: ProfileError) in
                guard let self else { return "Something went wrong. Please try again." }
                switch error {
                case .network(let rawMessage):
                    return self.decodeServerMessage(rawMessage)
                }
            },
            onSuccess: { [weak self] profile in
                self?.userProfile = profile
                self?.updateCurrentPlan(from: profile.data.user)
                self?.getHistory()
            }
        )
    }

    private func getHistory() {
        performWithLoading(
            operation: { [weak self] completion in
                guard let self else { return }
                self.userUseCase.fetchSubscriptionHistory { result in
                    completion(result)
                }
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

    private func updateCurrentPlan(from user: User) {
        let planTitle: String
        switch user.premiumPlan?.lowercased() {
        case "yearly":
            planTitle = "You're on the Yearly Plan"
        case "monthly":
            planTitle = "You're on the Monthly Plan"
        default:
            planTitle = "You're on the Premium Plan"
        }

        var subtitle: String?
        if let expiresAtString = user.premiumExpiresAt {
            let iso = ISO8601DateFormatter()
            iso.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

            if let date = iso.date(from: expiresAtString) {
                let formatter = DateFormatter()
                formatter.dateFormat = "d MMM yyyy"
                let dateString = formatter.string(from: date)
                subtitle = "Renews on \(dateString)"
            }
        }

        currentPlan = CurrentPlanViewData(
            title: planTitle,
            subtitle: subtitle
        )
    }

    private func mapHistory(_ history: SubscriptionHistory) -> [SubscriptionHistoryItemViewData] {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        let displayFormatter = DateFormatter()
        displayFormatter.dateFormat = "d MMM yyyy"

        let events = history.data?.events ?? []

        return events.map { event in
            let planText: String
            switch event.plan?.lowercased() {
            case "yearly":
                planText = "Yearly plan"
            case "monthly":
                planText = "Monthly plan"
            default:
                planText = "Subscription"
            }

            let actionText: String
            if !(event.isActive ?? false) {
                actionText = "deactivated"
            } else {
                switch event.type {
                case "initial_purchase":
                    actionText = "started"
                case "renewal":
                    actionText = "renewed"
                case "product_change":
                    actionText = "changed"
                case "restore":
                    actionText = "restored"
                default:
                    actionText = "updated"
                }
            }

            let title = "\(planText) \(actionText)"

            var dateText = event.date ?? ""
            if let raw = event.date,
               let date = isoFormatter.date(from: raw) {
                dateText = displayFormatter.string(from: date)
            }

            let statusText = (event.isActive ?? false) ? "Completed" : "Inactive"

            return SubscriptionHistoryItemViewData(
                title: title,
                dateText: dateText,
                statusText: statusText
            )
        }
    }
}
