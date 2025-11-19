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
