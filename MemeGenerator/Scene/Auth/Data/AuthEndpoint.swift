//
//  AuthEndpoint.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 18.11.25.
//

import Foundation

enum AuthEndpoint {
    case login
    case register

    case verifyEmail
    case resendEmailCode

    case forgotPassword
    case resetPassword

    var path: String {
        switch self {
        case .login:
            return NetworkHelper.shared.configureURL(endpoint: "/auth/login")
        case .register:
            return NetworkHelper.shared.configureURL(endpoint: "/auth/register")

        case .verifyEmail:
            return NetworkHelper.shared.configureURL(endpoint: "/auth/verify-email")
        case .resendEmailCode:
            return NetworkHelper.shared.configureURL(endpoint: "/auth/resend-email-code")

        case .forgotPassword:
            return NetworkHelper.shared.configureURL(endpoint: "/auth/forgot-password")
        case .resetPassword:
            return NetworkHelper.shared.configureURL(endpoint: "/auth/reset-password")
        }
    }
}
