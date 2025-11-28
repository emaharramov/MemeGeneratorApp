//
//  CreateRouting.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 29.11.25.
//

import UIKit

protocol CreateRouting: AnyObject {

    func makeAIMeme() -> UIViewController
    func makeAIWithTemplate() -> UIViewController
    func makeCustomMeme() -> UIViewController

    func showPremium()
    func showAuth()
}
