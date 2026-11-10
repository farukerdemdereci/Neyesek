//
//  AuthServiceProtocol.swift
//  PinEatUIKit
//
//  Created by Faruk Dereci on 19.12.2025.
//

import Foundation

protocol AuthServiceProtocol {

    func signInWithApple(idToken: String) async throws

    func signInWithGoogle() async throws

    func signInAnonymously() async throws

    func signOut() async throws

    var currentUserEmail: String? { get }

    func deleteAccount() async throws
}
