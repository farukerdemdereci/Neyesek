//
//  Service.swift
//  PinEatUIKit
//
//  Created by Faruk Dereci on 18.12.2025.
//

import Foundation
import UIKit
import GoogleSignIn
import Supabase

final class SupabaseManager {
    let client: SupabaseClient

    init(client: SupabaseClient) {
        self.client = client
    }

    private func requireUserId() async throws -> UUID {
        let session = try await client.auth.session
        return session.user.id
    }
}

extension SupabaseManager: AuthServiceProtocol {

    func signInWithGoogle() async throws {
        guard let clientID = Bundle.main.object(forInfoDictionaryKey: "GIDClientID") as? String else {
            throw NetworkError.invalidResponse
        }

        GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)

        guard
            let windowScene = await UIApplication.shared.connectedScenes.first as? UIWindowScene,
            let rootViewController = await windowScene.windows.first?.rootViewController
        else {
            throw NetworkError.invalidResponse
        }

        let result = try await GIDSignIn.sharedInstance.signIn(
            withPresenting: rootViewController
        )

        guard let idToken = result.user.idToken?.tokenString else {
            throw NetworkError.invalidResponse
        }

        try await client.auth.signInWithIdToken(
            credentials: .init(
                provider: .google,
                idToken: idToken
            )
        )
    }

    func signInWithApple(idToken: String) async throws {
        try await client.auth.signInWithIdToken(
            credentials: .init(
                provider: .apple,
                idToken: idToken
            )
        )
    }

    func signOut() async throws {
        GIDSignIn.sharedInstance.signOut()
        try await client.auth.signOut()
    }
}

extension SupabaseManager: FavoritePlaceServiceProtocol {
    func fetchFavoritePlaces() async throws -> [FavoritePlace] {
        
        let userId = try await requireUserId()
 
        let favoritePlaces: [FavoritePlace] = try await client
            .from("places")
            .select()
            .eq("user_id", value: userId)
            .execute()
            .value
        
        return favoritePlaces
    }
    
    func saveFavoritePlace(name: String, category: String, latitude: Double, longitude: Double, placeId: String, price: Int?, rating: Double?, ratingCount: Int?) async throws {
        
        let userId = try await requireUserId()

        let favoritePlace = FavoritePlace(
            id: UUID(),
            userId: userId,
            placeId: placeId,
            name: name,
            category: category,
            latitude: latitude,
            longitude: longitude,
            price: price,
            rating: rating,
            ratingCount: ratingCount
        )

        try await client
            .from("places")
            .insert(favoritePlace)
            .execute()
    }

    func deleteFavoritePlace(id: UUID) async throws {
        try await client
            .from("places")
            .delete()
            .eq("id", value: id)
            .execute()
    }
}
