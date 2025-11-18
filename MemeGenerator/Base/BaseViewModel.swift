//
//  BaseViewModel.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 18.11.25.
//

import Foundation
import Combine

/// Base class for ViewModels providing common loading/error state and a Combine store.
/// Annotated with `@MainActor` to ensure UI-bound state updates occur on the main thread.
@MainActor
class BaseViewModel {

    // MARK: - Published State

    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

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

    func resetError() {
        errorMessage = nil
    }
}
