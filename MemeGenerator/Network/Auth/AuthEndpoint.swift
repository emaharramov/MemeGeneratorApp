//
//  AuthEndpoint.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 18.11.25.
//

import Foundation

enum AuthEndpoint {
    case login
    case register
    
    var path: String {
        switch self {
        case .login:
            return NetworkHelper.shared.configureURL(endpoint: "/auth/login")
        case .register:
            return NetworkHelper.shared.configureURL(endpoint: "/auth/register")
        }
    }
}
