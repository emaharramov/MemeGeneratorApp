//
//  AppStorage.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 18.11.25.
//

import Foundation

/// A thin, type-safe wrapper around UserDefaults to centralize app-wide flags and tokens.
/// Use `AppStorage.shared` to access. Avoid using raw UserDefaults keys elsewhere in the app.
final class AppStorage {

    // MARK: - Nested Types

    private enum Key: String {
        case hasSeenOnboarding
        case token
    }

    // MARK: - Singleton

    static let shared = AppStorage()
    private init() {}

    // MARK: - Dependencies

    private let defaults: UserDefaults = .standard

    // MARK: - Properties

    var token: String? {
        get { defaults.string(forKey: "token") }
        set { defaults.setValue(newValue, forKey: "token") }
    }

    var isLoggedIn: Bool {
        get { token != nil }
        set {
            if newValue == false {
                token = nil
            }
        }
    }

    var hasSeenOnboarding: Bool {
        get { defaults.bool(forKey: "hasSeenOnboarding") }
        set { defaults.setValue(newValue, forKey: "hasSeenOnboarding") }
    }

    // MARK: - Actions

    /// Clears all authentication-related state.
    func logout() {
        defaults.removeObject(forKey: Key.token.rawValue)
    }
}
