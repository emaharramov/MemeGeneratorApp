//
//  AuthRequestModel.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 03.12.25.
//

import Foundation

protocol AuthRequestModel: Codable {}

extension AuthRequestModel {
    func toDictionary() -> [String: Any]? {
        do {
            let data = try JSONEncoder().encode(self)
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
            return jsonObject as? [String: Any]
        } catch {
            print("❌ AuthRequestModel toDictionary error: \(error)")
            return nil
        }
    }
}
