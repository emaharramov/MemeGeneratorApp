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
            completion(.success(model))
        }
    }

    func register(
        email: String,
        username: String,
        password: String,
        completion: @escaping (Result<RegisterStartResponseModel, AuthError>) -> Void
    ) {
        let credentials = AuthRegisterRequestModel(email: email, username: username, password: password)

        performAuthRequest(
            endpoint: .register,
            credentials: credentials,
            responseType: RegisterStartResponseModel.self
        ) { response, errorMessage in

            if let errorMessage {
                completion(.failure(self.mapError(from: errorMessage)))
                return
            }

            guard let model = response else {
                completion(.failure(.decoding))
                return
            }

            completion(.success(model))
        }
    }

    func verifyEmail(
        email: String,
        code: String,
        completion: @escaping (Result<AuthLoginResponseModel, AuthError>) -> Void
    ) {
        let req = VerifyEmailRequestModel(email: email, code: code)

        performAuthRequest(
            endpoint: .verifyEmail,
            credentials: req,
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
            completion(.success(model))
        }
    }

    func resendEmailCode(
        email: String,
        completion: @escaping (Result<SimpleServerMessageResponse, AuthError>) -> Void
    ) {
        let req = ResendEmailCodeRequestModel(email: email)

        performAuthRequest(
            endpoint: .resendEmailCode,
            credentials: req,
            responseType: SimpleServerMessageResponse.self
        ) { response, errorMessage in
            if let errorMessage {
                completion(.failure(self.mapError(from: errorMessage)))
                return
            }
            guard let model = response else {
                completion(.failure(.decoding))
                return
            }
            completion(.success(model))
        }
    }

    func forgotPassword(
        email: String,
        completion: @escaping (Result<SimpleServerMessageResponse, AuthError>) -> Void
    ) {
        let req = ForgotPasswordRequestModel(email: email)

        performAuthRequest(
            endpoint: .forgotPassword,
            credentials: req,
            responseType: SimpleServerMessageResponse.self
        ) { response, errorMessage in

            if let errorMessage {
                completion(.failure(self.mapError(from: errorMessage)))
                return
            }

            guard let model = response else {
                completion(.failure(.decoding))
                return
            }

            completion(.success(model))
        }
    }

    func resetPassword(
        email: String,
        code: String,
        newPassword: String,
        completion: @escaping (Result<AuthLoginResponseModel, AuthError>) -> Void
    ) {
        let req = ResetPasswordRequestModel(email: email, code: code, newPassword: newPassword)

        performAuthRequest(
            endpoint: .resetPassword,
            credentials: req,
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

            completion(.success(model))
        }
    }

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

    private func mapError(from message: String) -> AuthError {
        let lower = message.lowercased()

        if lower.contains("credential") || lower.contains("unauthorized") || lower.contains("401") {
            return .invalidCredentials
        }

        if lower.contains("network") || lower.contains("offline") || lower.contains("internet") {
            return .network(message)
        }

        return .server(message)
    }
}
