//
//  HomeManager.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 24.11.25.
//

import Foundation
import Alamofire

final class HomeManager {
    static let shared = HomeManager()
    private let networkManager = NetworkManager()
    
    private init() {}
    
    func getAllTemplates(completion: @escaping (AllMemes?, String?) -> Void) {
        
        let path = HomeEndpoint.allTemplates.path
        
        networkManager.request(path: path,
                               model: AllMemes.self,
                               method: .get,
                               encodingType: .json,
                               completion: completion)
    }
    
}
