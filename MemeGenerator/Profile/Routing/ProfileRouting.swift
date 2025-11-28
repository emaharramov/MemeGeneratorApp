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
    func showMyMemes()
    func showSavedMemes()
    func showSettings()
    func showHelp()
    func performLogout()
}
