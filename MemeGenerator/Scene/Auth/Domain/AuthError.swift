//
//  AuthError.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 29.11.25.
//

import Foundation

enum AuthError: Error {
    case invalidCredentials
    case network(String)
    case server(String)
    case decoding
    case unknown
}
