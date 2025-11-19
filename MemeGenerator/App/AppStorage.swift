//
//  AppStorage.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 18.11.25.
//

import Foundation

/// Centralized wrapper around UserDefaults for all app-wide persistent values.
final class AppStorage {

    // MARK: - Keys
    private enum Key: String {
        case token
        case userId
        case hasSeenOnboarding
    }

    // MARK: - Singleton
    static let shared = AppStorage()
    private init() {}

    private let defaults = UserDefaults.standard

    // MARK: - Auth Data

    /// JWT token returned from backend login.
    var token: String? {
        get { defaults.string(forKey: "token") }
        set { defaults.setValue(newValue, forKey: "token") }
    }

    /// Logged-in userId (MongoDB `_id`)
    var userId: String {
        get { defaults.string(forKey: Key.userId.rawValue) ?? "" }
        set { defaults.setValue(newValue, forKey: Key.userId.rawValue) }
    }

    /// Whether user is authenticated
    var isLoggedIn: Bool {
        get { token != nil }
        set {
            if newValue == false {
                token = nil
            }
        }
    }

    // MARK: - Onboarding

    var hasSeenOnboarding: Bool {
        get { defaults.bool(forKey: Key.hasSeenOnboarding.rawValue) }
        set { defaults.setValue(newValue, forKey: Key.hasSeenOnboarding.rawValue) }
    }

    // MARK: - Actions

    /// Saves credentials after login
    func saveLogin(token: String, userId: String) {
        self.token = token
        self.userId = userId
    }

    /// Clears all auth-related state
    func logout() {
        defaults.removeObject(forKey: Key.token.rawValue)
        defaults.removeObject(forKey: Key.userId.rawValue)
    }
}
