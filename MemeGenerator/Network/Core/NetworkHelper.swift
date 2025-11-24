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
    
    var headers: HTTPHeaders {
          if let token = UserDefaults.standard.string(forKey: "authToken"), !token.isEmpty {
              return ["Authorization": "Bearer \(token)"]
          } else {
              return [:]
          }
      }
    
    func configureURL(endpoint: String) -> String {
        return Constants.baseURL + endpoint
    }
}

extension NetworkHelper {
    enum Constants {
        static let baseURL = "https://memegenerator-backend.vercel.app/v1/api"
    }
}
