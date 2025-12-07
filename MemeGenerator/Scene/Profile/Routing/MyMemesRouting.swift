//
//  MyMemesRouting.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 06.12.25.
//

import UIKit

protocol MyMemesRouting: AnyObject {
    func makeAIMemes() -> UIViewController
    func makeAIMemesWithTemplate() -> UIViewController
}
