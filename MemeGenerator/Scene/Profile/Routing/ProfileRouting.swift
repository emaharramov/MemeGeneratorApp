//
//  ProfileRouting.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 29.11.25.
//

import UIKit

protocol ProfileRouting: AnyObject {
    func showEditProfile()
    func showPremium()
    func showSubscription()
    func showMyMemes()
    func showHelp()
    func performLogout()
    func showSupport()
}
