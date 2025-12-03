//
//  MemeEndpoint.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 19.11.25.
//

import Foundation

enum MemeEndpoint {
    // MEME
    case create
    case createAI
    case userMemes(userId: String)
    case all

    // TEMPLATE
    case templates

    var path: String {
        switch self {
        case .create:
            return NetworkHelper.shared.configureURL(endpoint: "/memes")
            
        case .createAI:
            return NetworkHelper.shared.configureURL(endpoint: "/memes/create-ai")

        case .userMemes(let userId):
            return NetworkHelper.shared.configureURL(endpoint: "/memes/\(userId)")

        case .all:
            return NetworkHelper.shared.configureURL(endpoint: "/memes/all")

        case .templates:
            return NetworkHelper.shared.configureURL(endpoint: "/templates")
        }
    }
}

