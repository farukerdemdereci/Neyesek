//
//  PlaceSearchServiceProtocol.swift
//  Pineat
//
//  Created by Faruk on 25.03.2026.
//

import Foundation
import CoreLocation

protocol PlaceServiceProtocol {
    var isAPIKeyMissing: Bool { get }

    func fetchPlaces(userLocation: UserLocation, filter: PlaceFilter) async throws -> [Place]

    func fetchFavoritePlaceOpenStatus(placeId: String) async throws -> Bool?
}
