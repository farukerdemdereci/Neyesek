//
//  PlaceService.swift
//  Pineat
//
//  Created by Faruk on 25.03.2026.
//

import Foundation
import CoreLocation

final class PlaceService: PlaceServiceProtocol {

    private let googleService: SupabasePlacesService

    init(googleService: SupabasePlacesService) {
        self.googleService = googleService
    }

    var isAPIKeyMissing: Bool {
        false
    }
    
    func fetchPlaces(
        userLocation: UserLocation,
        filter: PlaceFilter
    ) async throws -> [Place] {

        print("PLACE SERVICE CALLED")
        
        let dtos = try await googleService.fetchPlaces(
            lat: userLocation.latitude,
            lng: userLocation.longitude,
            category: filter.category,
            radius: filter.radius ?? 600,
            price: filter.price
        )

        var places = dtos.map { mapToPlace($0, filter: filter) }

        if let minimumRating = filter.minRating {
            places = places.filter { ($0.rating ?? 0) >= minimumRating }
        }

        if let maxPrice = filter.price {
            places = places.filter { place in
                guard let placePrice = place.price else { return false }
                return placePrice <= maxPrice
            }
        }

        return places
    }

    func fetchFavoritePlaceOpenStatus(
        placeId: String
    ) async throws -> Bool? {
        throw NetworkError.statusCode(429)
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
