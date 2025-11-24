//
//  NetworkManager.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 18.11.25.
//

import Foundation
import Alamofire

class NetworkManager {

    func request<T: Codable>(path: String,
                             model: T.Type,
                             method: HTTPMethod = .get,
                             params: Parameters? = nil,
                             encodingType: EncodingType = .url,
                             header: HTTPHeaders? = nil,
                             completion: @escaping((T?, String?) -> Void)) {
    
        AF.request(path,
                   method: method,
                   parameters: params,
                   encoding: encodingType == .url ? URLEncoding.default : JSONEncoding.default,
                   headers: NetworkHelper.shared.headers)
        .validate()
        .responseDecodable(of: model.self) { response in
            switch response.result {
            case .success(let data):
                completion(data, nil)
            case .failure(let error):
                completion(nil, error.localizedDescription)
            }
        }
    }
}
