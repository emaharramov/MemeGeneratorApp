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
    let pageInfo: PageInfo?
}

struct PageInfo: Codable, Sendable {
    let hasNext: Bool?
    let page: Int?
}

// MARK: - MemesTemplate
struct MemesTemplate: Codable, Hashable, Sendable {
     let id: String?
     let userID: String?
     let prompt: String?
     let imageURL: String?
     let createdAt, updatedAt: String?
     let v: Int?
     let username: String?

     enum CodingKeys: String, CodingKey {
         case id = "_id"
         case userID = "userId"
         case prompt
         case imageURL = "imageUrl"
         case createdAt, updatedAt
         case v = "__v"
         case username
     }
}
