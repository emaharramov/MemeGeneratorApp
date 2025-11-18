//
//  LogoutService.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 18.11.25.
//

import UIKit

final class LogoutService {

    static let shared = LogoutService()
    private init() {}

    func logout() {
        // Clear stored values
        AppStorage.shared.token = nil
        AppStorage.shared.isLoggedIn = false

        // Restart app flow using coordinator
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let sceneDelegate = scene.delegate as? SceneDelegate,
           let coordinator = sceneDelegate.coordinator {
            coordinator.start()
        }
    }
}
