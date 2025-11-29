//
//  AppStorage.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 18.11.25.
//

import Foundation

final class AppStorage {

    private enum Key: String {
        case token
        case userId
        case hasSeenOnboarding
    }

    static let shared = AppStorage()
    private init() {}

    private let defaults = UserDefaults.standard

    var token: String? {
        get { defaults.string(forKey: "token") }
        set { defaults.setValue(newValue, forKey: "token") }
    }

    var userId: String {
        get { defaults.string(forKey: Key.userId.rawValue) ?? "" }
        set { defaults.setValue(newValue, forKey: Key.userId.rawValue) }
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
        get { defaults.bool(forKey: Key.hasSeenOnboarding.rawValue) }
        set { defaults.setValue(newValue, forKey: Key.hasSeenOnboarding.rawValue) }
    }

    func saveLogin(token: String, userId: String) {
        self.token = token
        self.userId = userId
    }
}
