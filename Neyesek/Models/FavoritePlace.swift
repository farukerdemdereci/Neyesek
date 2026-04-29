//
//  FavoritePlace.swift
//  Pineat
//
//  Created by Faruk on 25.03.2026.
//

import Foundation

struct FavoritePlace: Codable {
    let id: UUID
    let userId: UUID
    let placeId: String
    let name: String
    let category: String
    let latitude: Double
    let longitude: Double
    let price: Int?
    let rating: Double?
    let ratingCount: Int?
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case placeId = "place_id"
        case name
        case latitude
        case longitude
        case category
        case price
        case rating
        case ratingCount = "rating_count"
    }
}
