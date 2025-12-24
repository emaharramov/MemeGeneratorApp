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
    case aiMemes(userId: String,page: Int)
    case aiTempMemes(userId: String,page: Int)
    case paymentHistory

    var path: String {
        switch self {
        case .me, .updateMe:
            return NetworkHelper.shared.configureURL(endpoint: "/users/me")
        case .aiMemes(let userId, let page):
            return NetworkHelper.shared.configureURL(endpoint: "/memes/ai/\(userId)?page=\(page)")
        case .aiTempMemes(let userId, let page):
            return NetworkHelper.shared.configureURL(endpoint: "/memes/aitemp/\(userId)?page=\(page)")
        case .paymentHistory:
            return NetworkHelper.shared.configureURL(endpoint: "/users/subscription/history")
        }
    }
}
