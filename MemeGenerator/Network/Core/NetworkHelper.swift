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

final class NetworkHelper {
    static let shared = NetworkHelper()
    private init() {}

    var headers: HTTPHeaders {
        var headers: HTTPHeaders = [
            "Content-Type": "application/json"
        ]

        if let token = AppStorage.shared.accessToken,
           !token.isEmpty {
            headers["Authorization"] = "Bearer \(token)"
        }

        return headers
    }

    func configureURL(endpoint: String) -> String {
        return Constants.baseURL + endpoint
    }
}

extension NetworkHelper {
    enum Constants {
        static let baseURL = "https://memegenerator-backend.vercel.app/v1/api"
        // MARK: will removed
        static let baseURLFortest = "http://localhost:3000/v1/api"
    }
}
