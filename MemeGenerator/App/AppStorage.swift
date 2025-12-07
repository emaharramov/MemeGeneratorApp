//
//  AppStorage.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 18.11.25.
//

import Foundation

final class AppStorage {

    private enum Key: String {
        case accessToken
        case refreshToken
        case userId
        case user
        case hasSeenOnboarding
    }

    static let shared = AppStorage()
    private init() {}

    private let defaults = UserDefaults.standard

    var accessToken: String? {
        get { defaults.string(forKey: Key.accessToken.rawValue) }
        set { defaults.setValue(newValue, forKey: Key.accessToken.rawValue) }
    }

    var refreshToken: String? {
        get { defaults.string(forKey: Key.refreshToken.rawValue) }
        set { defaults.setValue(newValue, forKey: Key.refreshToken.rawValue) }
    }

    var userId: String {
        get { defaults.string(forKey: Key.userId.rawValue) ?? "" }
        set { defaults.setValue(newValue, forKey: Key.userId.rawValue) }
    }

    var currentUser: User? {
        get {
            guard let data = defaults.data(forKey: Key.user.rawValue) else {
                return nil
            }
            return try? JSONDecoder().decode(User.self, from: data)
        }
        set {
            if let newValue {
                let encoder = JSONEncoder()
                if let data = try? encoder.encode(newValue) {
                    defaults.set(data, forKey: Key.user.rawValue)
                }
            } else {
                defaults.removeObject(forKey: Key.user.rawValue)
            }
        }
    }

    var isPremiumUser: Bool {
        currentUser?.isPremium ?? false
    }

    var isLoggedIn: Bool {
        get { !(accessToken ?? "").isEmpty }
        set {
            guard newValue == false else { return }
            accessToken = nil
            refreshToken = nil
            userId = ""
            currentUser = nil
        }
    }

    var hasSeenOnboarding: Bool {
        get { defaults.bool(forKey: Key.hasSeenOnboarding.rawValue) }
        set { defaults.setValue(newValue, forKey: Key.hasSeenOnboarding.rawValue) }
    }

    func saveLogin(
        accessToken: String,
        userId: String,
        refreshToken: String? = nil,
        user: User? = nil
    ) {
        self.accessToken = accessToken
        self.userId = userId

        if let refreshToken {
            self.refreshToken = refreshToken
        }

        if let user {
            self.currentUser = user
        }
    }
}
