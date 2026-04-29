//
//  GooglePlacesResponseDTO.swift
//  Pineat
//
//  Created by Faruk on 23.04.2026.
//

import Foundation

struct GooglePlacesResponse: Decodable {
    let results: [PlacesDTO]
}

struct PlacesDTO: Decodable {
    let placeId: String
    let name: String
    let geometry: GeometryDTO
    let rating: Double?
    let userRatingsTotal: Int?
    let priceLevel: Int?
    let openingHours: OpeningHoursDTO?
    let types: [String]?

    enum CodingKeys: String, CodingKey {
        case placeId = "place_id"
        case name
        case geometry
        case rating
        case userRatingsTotal = "user_ratings_total"
        case priceLevel = "price_level"
        case openingHours = "opening_hours"
        case types
    }
}

struct GeometryDTO: Decodable {
    let location: LocationDTO
}

struct LocationDTO: Decodable {
    let lat: Double
    let lng: Double
}
