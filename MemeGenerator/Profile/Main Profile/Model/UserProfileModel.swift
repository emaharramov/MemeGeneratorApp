//
//  UserProfileModel.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 03.12.25.
//

import Foundation

struct UserProfileModel: Codable {
    let id: ID?
    let email, username, passwordHash: String?
    let createdAt, updatedAt: AtedAt?
    let v: V?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case email, username, passwordHash, createdAt, updatedAt
        case v = "__v"
    }
}

struct AtedAt: Codable {
    let date: DateClass?

    enum CodingKeys: String, CodingKey {
        case date = "$date"
    }
}

struct DateClass: Codable {
    let numberLong: String?

    enum CodingKeys: String, CodingKey {
        case numberLong = "$numberLong"
    }
}

struct ID: Codable {
    let oid: String?

    enum CodingKeys: String, CodingKey {
        case oid = "$oid"
    }
}

struct V: Codable {
    let numberInt: String?

    enum CodingKeys: String, CodingKey {
        case numberInt = "$numberInt"
    }
}
