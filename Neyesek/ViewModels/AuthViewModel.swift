//
//  AuthViewModel.swift
//  PinEatUIKit
//
//  Created by Faruk Dereci on 18.12.2025.
//

import Foundation

@MainActor
final class AuthViewModel: ObservableObject {

    @Published private(set) var state: ViewState<Void> = .idle

    private let authService: AuthServiceProtocol

    init(authService: AuthServiceProtocol) {
        self.authService = authService
    }

    func signInWithGoogle() async {
        state = .loading

        do {
            try await authService.signInWithGoogle()
            state = .success(())
        } catch {
            state = .error(error)
        }
    }

    func signInWithApple(idToken: String) async {
        state = .loading

        do {
            try await authService.signInWithApple(idToken: idToken)
            state = .success(())
        } catch {
            state = .error(error)
        }
    }

    func signOut() async {
        do {
            try await authService.signOut()
            state = .success(())
        } catch {
            state = .error(error)
        }
    }

    func resetState() {
        state = .idle
    }
}
