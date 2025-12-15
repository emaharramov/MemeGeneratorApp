//
//  SimpleServerMessageResponse.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 12.12.25.
//

import Foundation

struct SimpleServerMessageResponse: Codable {
    let success: Bool?
    let message: String?
}
