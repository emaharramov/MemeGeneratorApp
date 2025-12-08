//
//  PremiumEndPoint.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 08.12.25.
//

import Foundation

enum PremiumEndPoint {
    case premiumSync

    var path: String {
        switch self {
        case .premiumSync:
            return NetworkHelper.shared.configureURL(endpoint: "/users/premium/sync")

        }
    }
}
