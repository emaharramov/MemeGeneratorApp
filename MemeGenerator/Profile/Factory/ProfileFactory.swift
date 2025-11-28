//
//  ProfileFactory.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 29.11.25.
//

import UIKit

protocol ProfileFactory {
    func makeProfile(router: ProfileRouting) -> UIViewController
    func makeEditProfile() -> UIViewController
    func makePremium() -> UIViewController
    func makeMyMemes() -> UIViewController
    func makeSavedMemes() -> UIViewController
    func makeSettings() -> UIViewController
    func makeHelp() -> UIViewController
}

final class DefaultProfileFactory: ProfileFactory {

    func makeProfile(router: ProfileRouting) -> UIViewController {
        let vc = ProfileViewController(router: router)
        return vc
    }

    func makeEditProfile() -> UIViewController {
        let vm = EditProfileVM()
        let vc = EditProfileViewController(viewModel: vm)
        return vc
    }

    func makePremium() -> UIViewController {
        let vm = PremiumVM()
        let vc = PremiumViewController(viewModel: vm)
        return vc
    }

    func makeMyMemes() -> UIViewController {
        let vc = MyMemesViewController()
        return vc
    }

    func makeSavedMemes() -> UIViewController {
        let vc = SavedMemesViewController()
        return vc
    }

    func makeSettings() -> UIViewController {
        let vm = SettingsVM()
        let vc = SettingsViewController(viewModel: vm)
        return vc
    }

    func makeHelp() -> UIViewController {
        let vm = HelpFeedbackVM()
        let vc = HelpFeedbackVC(viewModel: vm)
        return vc
    }
}
