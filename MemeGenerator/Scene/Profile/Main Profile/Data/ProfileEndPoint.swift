//
//  ProfileEndPoint.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 03.12.25.
//

import Foundation

enum ProfileEndpoint {
    case me
    case updateMe
    case aiMemes(userId: String)
    case aiTempMemes(userId: String)

    var path: String {
        switch self {
        case .me, .updateMe:
            return NetworkHelper.shared.configureURL(endpoint: "/users/me")
        case .aiMemes(let userId):
            return NetworkHelper.shared.configureURL(endpoint: "/memes/ai/\(userId)")
        case .aiTempMemes(let userId):
            return NetworkHelper.shared.configureURL(endpoint: "/memes/aitemp/\(userId)")
        }
    }
}
