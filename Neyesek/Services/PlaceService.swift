//
//  PlaceService.swift
//  Pineat
//
//  Created by Faruk on 25.03.2026.
//

import Foundation
import CoreLocation

final class PlaceService: PlaceServiceProtocol {
    private let googleService: GooglePlacesService

    init(googleService: GooglePlacesService) {
        self.googleService = googleService
    }
    
    var isAPIKeyMissing: Bool {
        googleService.isAPIKeyMissing
    }
    
    func fetchPlaces(
        userLocation: UserLocation,
        filter: PlaceFilter
    ) async throws -> [Place] {
        let dtos = try await googleService.fetchPlaces(
            userLocation: userLocation,
            filter: filter
        )

        return dtos.map { mapToPlace($0, filter: filter) }
    }

    func fetchFavoritePlaceOpenStatus(
        placeId: String
    ) async throws -> Bool? {
        if let cachedStatus = PlaceDetailsCache.shared.get(placeID: placeId) {
            return cachedStatus
        }

        let details = try await googleService.fetchPlaceDetails(placeId: placeId)
        let isOpen = details.openingHours?.openNow

        PlaceDetailsCache.shared.save(placeID: placeId, isOpen: isOpen)

        return isOpen
    }

    private func mapToPlace(_ dto: PlacesDTO, filter: PlaceFilter) -> Place {
        Place(
            id: dto.placeId,
            name: dto.name,
            category: filter.displayCategory ?? "Yemek",
            latitude: dto.geometry.location.lat,
            longitude: dto.geometry.location.lng,
            price: dto.priceLevel,
            rating: dto.rating,
            ratingCount: dto.userRatingsTotal,
            isOpen: dto.openingHours?.openNow
        )
    }
}
