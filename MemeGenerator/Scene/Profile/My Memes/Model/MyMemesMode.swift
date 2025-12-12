//
//  MyMemesMode.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 12.12.25.
//

import Foundation

enum MyMemesMode {
    case ai
    case aiTemplate

    var title: String {
        switch self {
        case .ai: return "AI Meme"
        case .aiTemplate: return "AI + Template"
        }
    }
 
    var badgeText: String {
        switch self {
        case .ai: return "AI"
        case .aiTemplate: return "AI+T"
        }
    }
}
