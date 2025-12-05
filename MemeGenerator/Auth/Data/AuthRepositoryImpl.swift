//
//  AuthRepositoryImpl.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 29.11.25.
//

import Foundation
import Alamofire

final class AuthRepositoryImpl: AuthRepository {

    private let networkManager: NetworkManager

    init(networkManager: NetworkManager) {
        self.networkManager = networkManager
    }

    // MARK: - Login

    func login(
        email: String,
        password: String,
        completion: @escaping (Result<AuthLoginResponseModel, AuthError>) -> Void
    ) {
        let credentials = AuthLoginRequestModel(email: email, password: password)

        performAuthRequest(
            endpoint: .login,
            credentials: credentials,
            responseType: AuthLoginResponseModel.self
        ) { response, errorMessage in

            if let errorMessage {
                completion(.failure(self.mapError(from: errorMessage)))
                return
            }

            guard let model = response else {
                completion(.failure(.decoding))
                return
            }

            let session = AuthLoginResponseModel(
                accessToken: model.accessToken,
                refreshToken: model.refreshToken,
                userId: model.userId
            )
            completion(.success(session))
        }
    }

    // MARK: - Register

    func register(
        email: String,
        username: String,
        password: String,
        completion: @escaping (Result<AuthLoginResponseModel, AuthError>) -> Void
    ) {
        let credentials = AuthRegisterRequestModel(
            email: email,
            username: username,
            password: password
        )

        performAuthRequest(
            endpoint: .register,
            credentials: credentials,
            responseType: AuthLoginResponseModel.self
        ) { response, errorMessage in

            if let errorMessage {
                completion(.failure(self.mapError(from: errorMessage)))
                return
            }

            guard let model = response else {
                completion(.failure(.decoding))
                return
            }

            let session = AuthLoginResponseModel(
                accessToken: model.accessToken,
                refreshToken: model.refreshToken,
                userId: model.userId
            )
            completion(.success(session))
        }
    }

    // MARK: - Private generic helper

    private func performAuthRequest<Response: Codable, Request: AuthRequestModel>(
        endpoint: AuthEndpoint,
        credentials: Request,
        responseType: Response.Type,
        completion: @escaping (Response?, String?) -> Void
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

    // MARK: - Error mapping

    private func mapError(from message: String) -> AuthError {
        let lower = message.lowercased()

        if lower.contains("credential") ||
            lower.contains("unauthorized") ||
            lower.contains("401") {
            return .invalidCredentials
        }

        if lower.contains("network") ||
            lower.contains("offline") ||
            lower.contains("internet") {
            return .network(message)
        }

        return .server(message)
    }
}
