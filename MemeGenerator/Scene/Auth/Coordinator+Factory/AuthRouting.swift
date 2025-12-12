//
//  AuthRouting.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 12.12.25.
//

protocol AuthRouting: AnyObject {
    func showForgotPassword()
    func authDidFinish(accessToken: String)
}
