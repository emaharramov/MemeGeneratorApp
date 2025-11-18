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

    var hasSeenOnboarding: Bool {
        get { defaults.bool(forKey: Key.hasSeenOnboarding.rawValue) }
        set { defaults.set(newValue, forKey: Key.hasSeenOnboarding.rawValue) }
    }

    var token: String? {
        get { defaults.string(forKey: Key.token.rawValue) }
        set { defaults.set(newValue, forKey: Key.token.rawValue) }
    }

    var isLoggedIn: Bool { token?.isEmpty == false }

    // MARK: - Actions

    /// Clears all authentication-related state.
    func logout() {
        defaults.removeObject(forKey: Key.token.rawValue)
    }
}
