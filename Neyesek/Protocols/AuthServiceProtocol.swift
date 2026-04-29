//
//  AuthServiceProtocol.swift
//  PinEatUIKit
//
//  Created by Faruk Dereci on 19.12.2025.
//

import Foundation

protocol AuthServiceProtocol {
    func signInWithGoogle() async throws
    
    func signInWithApple(idToken: String) async throws
    
    func signOut() async throws
}
