//
//  Place.swift
//  PinEatUIKit
//
//  Created by Faruk Dereci on 18.12.2025.
//

import Foundation

struct Place: Codable, Equatable {
    let id: String
    let name: String
    let category: String?
    let latitude: Double
    let longitude: Double
    let price: Int?
    let rating: Double?
    let ratingCount: Int?
    let isOpen: Bool?
}
