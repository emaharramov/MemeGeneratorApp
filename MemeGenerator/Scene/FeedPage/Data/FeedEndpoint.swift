//
//  FeedEndpoint.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 24.11.25.
//

import Foundation

enum FeedEndpoint {
    case allAIMemes(page: Int)
    
    var path: String {
        switch self {
        case .allAIMemes(let page):
            return NetworkHelper.shared.configureURL(
                           endpoint: "/memes/ai/all?page=\(page)")
        }
    }
}
