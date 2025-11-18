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

class NetworkHelper {
    static let shared = NetworkHelper()
    private let baseURL = "http://localhost:3000/v1/api"
    
    var headers: HTTPHeaders {
          if let token = UserDefaults.standard.string(forKey: "authToken"), !token.isEmpty {
              return ["Authorization": "Bearer \(token)"]
          } else {
              return [:]
          }
      }
    
    func configureURL(endpoint: String) -> String {
        return baseURL + endpoint
    }
}
