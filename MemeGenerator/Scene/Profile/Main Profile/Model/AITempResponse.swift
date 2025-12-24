//
//  AITempResponse.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 05.12.25.
//

import Foundation

struct AITempResponse: Codable {
    let success: Bool?
    var memes: [AiTempMeme]?
    let pageInfo: PageInfo?
}

struct AiTempMeme: Codable {
    let id, userID, templateID, topText: String?
    let bottomText: String?
    let imageURL: String?
    let createdAt, updatedAt: String?
    let v: Int?
    let username: String?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case userID = "userId"
        case templateID = "templateId"
        case topText, bottomText
        case imageURL = "imageUrl"
        case createdAt, updatedAt
        case v = "__v"
        case username
    }
}
