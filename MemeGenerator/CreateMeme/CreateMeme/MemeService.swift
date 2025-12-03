//
//  MemeManager.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 19.11.25.
//

import Foundation
import Alamofire
import UIKit

final class MemeService {

    static let shared = MemeService()
    private init() {}

    private let networkManager = NetworkManager()

    // MARK: - Generic Request
    private func performRequest<T: Codable>(
        endpoint: MemeEndpoint,
        method: HTTPMethod = .get,
        params: [String: Any]? = nil,
        responseType: T.Type,
        completion: @escaping (T?, String?) -> Void
    ) {
        networkManager.request(
            path: endpoint.path,
            model: responseType,
            method: method,
            params: params,
            encodingType: .json,
            header: NetworkHelper.shared.headers,
            completion: completion
        )
    }

    // MARK: - Generate Meme
    func generateMeme(
        userId: String,
        prompt: String,
        templateId: String,
        completion: @escaping (MemeDTO?, String?) -> Void
    ) {
        let params: [String: Any] = [
            "userId": userId,
            "prompt": prompt,
            "templateId": templateId
        ]

        networkManager.request(
            path: MemeEndpoint.create.path,
            model: MemeResponse.self,
            method: .post,
            params: params,
            encodingType: .json
        ) { response, error in
            if let err = error {
                completion(nil, err)
                return
            }
            completion(response?.meme, nil)
        }
    }

    func generateMemeAI(
        userId: String,
        prompt: String,
        completion: @escaping (MemeWithAI?, String?) -> Void
    ) {
        let params: [String: Any] = [
            "userId": userId,
            "prompt": prompt
        ]

        networkManager.request(
            path: MemeEndpoint.createAI.path,
            model: MemeWithAI.self,
            method: .post,
            params: params,
            encodingType: .json
        ) { response, error in
            if let err = error {
                completion(nil, err)
                return
            }
            completion(response, nil)
        }
    }

    // MARK: - User Meme History
    func fetchUserMemes(
        userId: String,
        completion: @escaping ([MemeDTO]?, String?) -> Void
    ) {
        performRequest(
            endpoint: .userMemes(userId: userId),
            responseType: MemeResponse.self
        ) { response, error in
            if let err = error { completion(nil, err); return }
            completion(response?.memes, nil)
        }
    }

    // MARK: - All Memes
    func fetchAllMemes(completion: @escaping ([MemeDTO]?, String?) -> Void) {
        performRequest(
            endpoint: .all,
            responseType: MemeResponse.self
        ) { response, error in
            if let err = error { completion(nil, err); return }
            completion(response?.memes, nil)
        }
    }

    // MARK: - Templates
    func fetchTemplates(completion: @escaping ([TemplateDTO]?, String?) -> Void) {
        performRequest(
            endpoint: .templates,
            responseType: TemplateListResponse.self
        ) { response, error in
            if let err = error { completion(nil, err); return }
            completion(response?.templates, nil)
        }
    }

    // MARK: - Load Image (AF)
    func loadImage(url: String, completion: @escaping (UIImage?) -> Void) {
        AF.request(url).responseData { res in
            guard let data = res.data else { completion(nil); return }
            completion(UIImage(data: data))
        }
    }
}
