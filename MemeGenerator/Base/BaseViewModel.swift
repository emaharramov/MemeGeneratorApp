//
//  BaseViewModel.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 18.11.25.
//

import Foundation
import Combine

class BaseViewModel: NSObject {

    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var successMessage: String?

    var shouldShowAd: ((@escaping () -> Void) -> Void)?
    var cancellables = Set<AnyCancellable>()

    override init() {}

    deinit {
        cancellables.removeAll()
    }

    func setLoading(_ value: Bool) {
        isLoading = value
    }

    func setError(_ message: String?) {
        errorMessage = message
    }

    func setSuccess(_ message: String?) {
        successMessage = message
    }

    func resetErrors() {
        resetMessages()
    }

    func resetMessages() {
        errorMessage = nil
        successMessage = nil
    }

    func beginLoading(resetMessages shouldReset: Bool = true) {
        if shouldReset {
            resetMessages()
        }
        isLoading = true
    }

    func endLoading() {
        isLoading = false
    }

    func showError(_ message: String) {
        errorMessage = message
    }

    func showSuccess(_ message: String) {
        successMessage = message
    }

    func store(_ cancellable: AnyCancellable) {
        cancellables.insert(cancellable)
    }

    func performWithLoading<T, E: Error>(
        resetMessages shouldReset: Bool = true,
        showAdForNonPremiumUser: Bool = true,
        operation: (@escaping (Result<T, E>) -> Void) -> Void,
        errorMapper: ((E) -> String)? = nil,
        onSuccess: @escaping (T) -> Void
    ) {
        if shouldReset {
            resetMessages()
        }

        setLoading(true)

        operation { [weak self] result in
            guard let self else { return }
            self.setLoading(false)

            switch result {
            case .success(let value):
                if showAdForNonPremiumUser && !self.isPremiumUser {
                    self.shouldShowAd? {
                        onSuccess(value)
                    }
                } else {
                    onSuccess(value)
                }

            case .failure(let error):
                if let errorMapper {
                    let message = errorMapper(error)
                    self.showError(message)
                }
            }
        }
    }

    private var isPremiumUser: Bool {
        return SubscriptionManager.shared.isPremium
    }
}

extension BaseViewModel {
    func decodeServerMessage(_ raw: String) -> String {
        struct ServerErrorResponse: Decodable {
            let success: Bool?
            let message: String?
        }

        guard !raw.isEmpty else {
            return "Something went wrong. Please try again."
        }

        if let data = raw.data(using: .utf8),
           let parsed = try? JSONDecoder().decode(ServerErrorResponse.self, from: data),
           let msg = parsed.message,
           !msg.isEmpty {
            return msg
        }

        return raw
    }
}
