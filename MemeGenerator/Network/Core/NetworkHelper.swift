//
//  NetworkHelper.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 18.11.25.
//

import Foundation
import Alamofire

enum EncodingType {
    case url
    case json
}

enum Environment {
    case dev, prod

    var baseURL: String {
        switch self {
        case .dev: return "http://localhost:3000/v1/api"
        case .prod: return "https://memegenerator-backend.vercel.app/v1/api"
        }
    }
}

final class NetworkHelper {
    static let shared = NetworkHelper()
    private init() {}

    var environment: Environment = .prod

    func configureURL(endpoint: String) -> String {
        return environment.baseURL + endpoint
    }

    var headers: HTTPHeaders {
        var headers: HTTPHeaders = [
            "Content-Type": "application/json"
        ]
        if let token = AppStorage.shared.accessToken, !token.isEmpty {
            headers["Authorization"] = "Bearer \(token)"
        }
        return headers
    }
}
