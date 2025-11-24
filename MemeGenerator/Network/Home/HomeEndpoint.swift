//
//  HomeEndpoint.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 24.11.25.
//

import Foundation

enum HomeEndpoint {
    case allTemplates
    
    var path: String {
        switch self {
        case .allTemplates:
            return NetworkHelper.shared.configureURL(endpoint: "/memes/all")
        }
    }
}
