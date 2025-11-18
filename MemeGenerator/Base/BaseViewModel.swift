//
//  BaseViewModel.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 18.11.25.
//

import Foundation
import Combine

/// Base class for all ViewModels with common UI-related states.
@MainActor
class BaseViewModel {

    // MARK: - Published UI State
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var successMessage: String?

    // MARK: - Combine
    var cancellables = Set<AnyCancellable>()

    // MARK: - Init
    init() {}

    // MARK: - Helpers
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
        errorMessage = nil
        successMessage = nil
    }
}
