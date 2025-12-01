//
//  FeedEndpoint.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 24.11.25.
//

import Foundation

enum FeedEndpoint {
    case allMemes
    case allAIMemes
    
    var path: String {
        switch self {
        case .allMemes:
            return NetworkHelper.shared.configureURL(endpoint: "/memes/all")
        case .allAIMemes:
            return NetworkHelper.shared.configureURL(endpoint: "/memes/ai/all")
        }
    }
}
