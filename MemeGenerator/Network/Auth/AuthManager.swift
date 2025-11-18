//
//  AuthManager.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 18.11.25.
//

import Foundation
import Alamofire

final class AuthManager {
    static let shared = AuthManager()
    private let networkManager = NetworkManager()

    private init() {}

    // MARK: - Generic Auth Request
    private func performAuthRequest<T: Codable>(
        endpoint: AuthEndpoint,
        credentials: AuthModel,
        responseType: T.Type,
        completion: @escaping (T?, String?) -> Void
    ) {
        guard let params = credentials.toDictionary() else {
            completion(nil, "Encoding error")
            return
        }

        networkManager.request(
            path: endpoint.path,
            model: responseType,
            method: .post,
            params: params,
            encodingType: .json,
            header: NetworkHelper.shared.headers,
            completion: completion
        )
    }

    // MARK: - Login
    func login(
        email: String,
        password: String,
        completion: @escaping (AuthLoginModel?, String?) -> Void
    ) {
        let credentials = AuthModel(email: email, password: password)

        performAuthRequest(
            endpoint: .login,
            credentials: credentials,
            responseType: AuthLoginModel.self,   // <- TOKEN MODEL
            completion: completion
        )
    }

    // MARK: - Register
    func register(
        email: String,
        password: String,
        completion: @escaping (AuthLoginModel?, String?) -> Void
    ) {
        let credentials = AuthModel(email: email, password: password)

        performAuthRequest(
            endpoint: .register,
            credentials: credentials,
            responseType: AuthLoginModel.self,   // <- backend register də token qaytarırsa
            completion: completion
        )
    }
}
