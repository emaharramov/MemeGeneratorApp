//
//  ResendEmailCodeUseCase.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 12.12.25.
//

import Foundation

protocol ResendEmailCodeUseCase {
    func execute(email: String,
                 completion: @escaping (Result<SimpleServerMessageResponse, AuthError>) -> Void)
}

