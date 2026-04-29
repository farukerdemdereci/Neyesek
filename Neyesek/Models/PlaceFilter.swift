//
//  PlaceFilter.swift
//  Pineat
//
//  Created by Faruk on 25.03.2026.
//

import Foundation

struct PlaceFilter: Equatable {
    let category: String?
    let radius: Int?
    let limit: Int?
    let price: Int?
    let minRating: Double?
    let openNow: Bool?
    let displayCategory: String?

    static let `default` = PlaceFilter(
        category: "pizza",
        radius: 600,
        limit: 20,
        price: nil,
        minRating: nil,
        openNow: nil,
        displayCategory: "Pizza"
    )
}
