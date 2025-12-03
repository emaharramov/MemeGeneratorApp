//
//  AIMemeError.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 30.11.25.
//

enum AIMemeError: Error {
    case network(String)
    case noMeme
    case imageDownloadFailed
}
