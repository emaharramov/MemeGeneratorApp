//
//  NetworkEndpoint.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 04.12.25.
//

import Foundation

enum NetworkEndpoint {
    case refresh

    var path: String {
        switch self {
        case .refresh:
            return NetworkHelper.shared.configureURL(endpoint: "/auth/refresh")
        }
    }
}
