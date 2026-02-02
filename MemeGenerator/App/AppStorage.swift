//
//  AppStorage.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 18.11.25.
//

import Foundation
import KeychainAccess

final class AppStorage {
    static let shared = AppStorage()
    private init() {}

    private enum Key: String {
        case accessToken, refreshToken, userId, hasSeenOnboarding
    }

    private let keychain = Keychain(service: "com.emil.MemeGenerator")
        .accessibility(.afterFirstUnlock)
    private let defaults = UserDefaults.standard

    var accessToken: String? {
        get { try? keychain.get(Key.accessToken.rawValue) }
        set { updateKeychain(key: .accessToken, value: newValue) }
    }

    var refreshToken: String? {
        get { try? keychain.get(Key.refreshToken.rawValue) }
        set { updateKeychain(key: .refreshToken, value: newValue) }
    }

    var userId: String {
        get { (try? keychain.get(Key.userId.rawValue)) ?? "" }
        set { updateKeychain(key: .userId, value: newValue.isEmpty ? nil : newValue) }
    }

    var hasSeenOnboarding: Bool {
        get { defaults.bool(forKey: Key.hasSeenOnboarding.rawValue) }
        set { defaults.set(newValue, forKey: Key.hasSeenOnboarding.rawValue) }
    }

    var isLoggedIn: Bool {
        accessToken?.isEmpty == false
    }

    var isPremiumUser: Bool {
        SubscriptionManager.shared.isPremium
    }

    func saveLogin(accessToken: String, userId: String, refreshToken: String? = nil) {
        self.accessToken = accessToken
        self.userId = userId
        self.refreshToken = refreshToken
        SubscriptionManager.shared.configureUserIfNeeded()
    }

    func logout() {
        accessToken = nil
        refreshToken = nil
        userId = ""
        SubscriptionManager.shared.logOut()
    }

    private func updateKeychain(key: Key, value: String?) {
        do {
            if let value = value {
                try keychain.set(value, key: key.rawValue)
            } else {
                try keychain.remove(key.rawValue)
            }
        } catch {
            print("DEBUG::: Keychain error (\(key)):", error)
        }
    }
}
