//
//  MemeResponse.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 19.11.25.
//

import Foundation

struct MemeResponse: Codable {
    let success: Bool
    let meme: MemeDTO?
    let memes: [MemeDTO]?
}

struct MemeDTO: Codable {
    let id: String?
    let imageUrl: String
    let prompt: String?
}

struct TemplateListResponse: Codable {
    let success: Bool
    let templates: [TemplateDTO]
}

struct TemplateDTO: Codable {
    let id: String
    let name: String
    let url: String
    let width: Int
    let height: Int
}

// MARK: - MemeWithAI
struct MemeWithAI: Codable {
    let success: Bool?
    let meme: Meme?
}

// MARK: - Meme
struct Meme: Codable {
    let userID, prompt: String?
    let imageURL: String?
    let id, createdAt, updatedAt: String?
    let v: Int?

    enum CodingKeys: String, CodingKey {
        case userID = "userId"
        case prompt
        case imageURL = "imageUrl"
        case id = "_id"
        case createdAt, updatedAt
        case v = "__v"
    }
}
