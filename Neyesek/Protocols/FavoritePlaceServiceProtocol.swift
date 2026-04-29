//
//  ListServiceProtocol.swift
//  PinEatUIKit
//
//  Created by Faruk Dereci on 26.12.2025.
//

import Foundation

protocol FavoritePlaceServiceProtocol {

    func fetchFavoritePlaces() async throws -> [FavoritePlace]

    func saveFavoritePlace(name: String, category: String, latitude: Double, longitude: Double, placeId: String, price: Int?, rating: Double?, ratingCount: Int?) async throws

    func deleteFavoritePlace(id: UUID) async throws
}
