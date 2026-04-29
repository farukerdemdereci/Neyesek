//
//  GooglePlaceDetailsResponse.swift
//  Pineat
//
//  Created by Faruk on 27.04.2026.
//

import Foundation

struct GooglePlaceDetailsResponse: Decodable {
    let result: PlaceDetailsDTO
}

struct PlaceDetailsDTO: Decodable {
    let openingHours: OpeningHoursDTO?

    enum CodingKeys: String, CodingKey {
        case openingHours = "opening_hours"
    }
}

struct OpeningHoursDTO: Decodable {
    let openNow: Bool?

    enum CodingKeys: String, CodingKey {
        case openNow = "open_now"
    }
}
