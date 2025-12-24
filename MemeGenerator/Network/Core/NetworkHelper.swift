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
        return Constants.baseURLFortest + endpoint
    }

//    func configureURL(endpoint: String, query: [String: String] = [:]) -> String {
//        var components = URLComponents(string: Constants.baseURL + endpoint)
//            if !query.isEmpty {
//                components?.queryItems = query.map { URLQueryItem(name: $0.key, value: $0.value) }
//            }
//        return components?.url?.absoluteString ?? (Constants.baseURLFortest + endpoint)
//    }
}

extension NetworkHelper {
    enum Constants {
        static let baseURL = "https://memegenerator-backend.vercel.app/v1/api"
        // MARK: will remove
        static let baseURLFortest = "http://localhost:3000/v1/api"
    }
}
