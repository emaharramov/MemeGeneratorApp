//
//  MemeDataError.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 03.12.25.
//

import UIKit

enum MemeDataError: LocalizedError {
    case api(message: String)
    case invalidResponse

    var errorDescription: String? {
        switch self {
        case .api(let message):
            return message
        case .invalidResponse:
            return "Unexpected response from server"
        }
    }
}
