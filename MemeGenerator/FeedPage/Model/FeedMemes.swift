//
//  FeedMemes.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 23.11.25.
//

import Foundation

// MARK: - AllMemes
struct FeedMemes: Codable, Sendable {
    let success: Bool?
    let memes: [MemesTemplate]?
}

// MARK: - MemesTemplate
struct MemesTemplate: Codable, Hashable, Sendable {
    let id: String?
    let userID: String?
    let templateID: String?
    let topText: String?
    let bottomText: String?
    let imageURL: String?
    let createdAt: String?
    let v: Int?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case userID = "userId"
        case templateID = "templateId"
        case topText, bottomText
        case imageURL = "imageUrl"
        case createdAt
        case v = "__v"
    }
}
