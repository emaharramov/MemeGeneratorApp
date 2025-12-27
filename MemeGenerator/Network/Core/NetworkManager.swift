//
//  NetworkManager.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 18.11.25.
//

import Foundation
import Alamofire

final class NetworkManager {

    static let shared = NetworkManager()

    func request<T: Decodable>(
        path: String,
        model: T.Type,
        method: HTTPMethod = .get,
        params: Parameters? = nil,
        encodingType: EncodingType = .url,
        header: HTTPHeaders? = nil,
        retries: Int = 1,
        shouldRetryOn401: Bool = true,
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
        .responseDecodable(of: model.self) { [weak self] response in
            guard let self else { return }

            let statusCode = response.response?.statusCode ?? -1

            if statusCode == 401, retries > 0, shouldRetryOn401 {
                Task {
                    let refreshed = await self.tryRefreshToken()
                    if refreshed {
                        await self.request(
                            path: path,
                            model: model,
                            method: method,
                            params: params,
                            encodingType: encodingType,
                            header: header,
                            retries: retries - 1,
                            shouldRetryOn401: shouldRetryOn401,
                            completion: completion
                        )
                    } else {
                        completion(nil, "Session expired. Please log in again.")
                    }
                }
                return
            }

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
                    message = "Status code: \(statusCode)"
                }
                completion(nil, message)
            }
        }
    }

    private func tryRefreshToken() async -> Bool {
        do {
            try await refreshToken()
            return true
        } catch {
            return false
        }
    }

    func refreshToken() async throws {
        let dataTask = AF.request(
            NetworkEndpoint.refresh.path,
            method: .post,
            parameters: [
                "refreshToken": AppStorage.shared.refreshToken
            ],
            encoding: JSONEncoding.default
        )
        .serializingDecodable(RefreshResponse.self)

        let model = try await dataTask.value
        AppStorage.shared.saveLogin(
            accessToken: model.data.accessToken,
            userId: model.data.user.id,
            refreshToken: model.data.refreshToken,
            user: model.data.user
        )
    }
}
