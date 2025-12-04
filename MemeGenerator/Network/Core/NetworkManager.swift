//
//  NetworkManager.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 18.11.25.
//

import Foundation
import Alamofire

final class NetworkManager {

    func request<T: Codable>(
        path: String,
        model: T.Type,
        method: HTTPMethod = .get,
        params: Parameters? = nil,
        encodingType: EncodingType = .url,
        header: HTTPHeaders? = nil,
        completion: @escaping ((T?, String?) -> Void)
    ) {
        let headers = header ?? NetworkHelper.shared.headers

        AF.request(
            path,
            method: method,
            parameters: params,
            encoding: encodingType == .url ? URLEncoding.default : JSONEncoding.default,
            headers: headers
        )
        .validate()
        .responseDecodable(of: model.self) { response in
            switch response.result {
            case .success(let data):
                completion(data, nil)
            case .failure:
                let message: String
                if let data = response.data,
                   let body = String(data: data, encoding: .utf8),
                   !body.isEmpty {
                    message = body
                } else {
                    message = "Status code: \(response.response?.statusCode ?? -1)"
                }
                completion(nil, message)
            }
        }
    }
}
