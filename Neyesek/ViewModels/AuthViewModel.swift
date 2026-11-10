//
//  AuthViewModel.swift
//  PinEatUIKit
//
//  Created by Faruk Dereci on 18.12.2025.
//

import Foundation

enum AuthMode {
    case guest
    case authenticated
}

@MainActor
final class AuthViewModel: ObservableObject {

    @Published private(set) var state: ViewState<Void> = .idle
    @Published private(set) var authMode: AuthMode = .guest

    private let authService: AuthServiceProtocol

    init(authService: AuthServiceProtocol) {
        self.authService = authService
    }

    func signInWithGoogle() async {
        state = .loading

        do {
            try await authService.signInWithGoogle()
            authMode = .authenticated
            state = .success(())
        } catch {
            state = .error(error)
        }
    }

    func signInWithApple(idToken: String) async {
        state = .loading

        do {
            try await authService.signInWithApple(idToken: idToken)
            authMode = .authenticated
            state = .success(())
        } catch {
            state = .error(error)
        }
    }

    func signInAnonymously() async {
        state = .loading

        do {
            try await authService.signInAnonymously()
            authMode = .guest
            state = .success(())
        } catch {
            state = .error(error)
        }
    }

    func deleteAccount() async {
        state = .loading

        do {
            try await authService.deleteAccount()
            try await authService.signOut()
            state = .success(())
        } catch {
            state = .error(error)
        }
    }

    func signOut() async {
        do {
            try await authService.signOut()
            authMode = .guest
            state = .success(())
        } catch {
            state = .error(error)
        }
    }

    var currentUserEmail: String {
        guard let email = authService.currentUserEmail,
              !email.isEmpty else {
            return "Misafir Kullanıcı"
        }

        return email
    }

    func resetState() {
        state = .idle
    }

    var isGuest: Bool {
        authMode == .guest
    }
}
