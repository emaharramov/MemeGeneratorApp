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

    var path: String {
        switch self {
        case .me, .updateMe:
            return NetworkHelper.shared.configureURL(endpoint: "/users/me")
        }
    }
}
