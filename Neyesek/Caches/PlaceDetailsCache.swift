//
//  PlaceDetailsCache.swift
//  Pineat
//
//  Created by Faruk on 28.04.2026.
//

import Foundation

final class PlaceDetailsCache {

    static let shared = PlaceDetailsCache()

    private let keyPrefix = "place_details_cache_"
    private let ttl: TimeInterval = 10 * 60

    private init() {}

    func get(placeID: String) -> Bool? {
        let key = cacheKey(placeID: placeID)

        guard let data = UserDefaults.standard.data(forKey: key),
              let cached = try? JSONDecoder().decode(CachedPlaceDetails.self, from: data)
        else {
            return nil
        }

        let isExpired = Date().timeIntervalSince(cached.createdAt) >= ttl

        if isExpired {
            UserDefaults.standard.removeObject(forKey: key)
            return nil
        }

        return cached.isOpen
    }

    func save(placeID: String, isOpen: Bool?) {
        let key = cacheKey(placeID: placeID)
        let cached = CachedPlaceDetails(createdAt: Date(), isOpen: isOpen)

        guard let data = try? JSONEncoder().encode(cached) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }

    private func cacheKey(placeID: String) -> String {
        keyPrefix + placeID
    }
}

private struct CachedPlaceDetails: Codable {
    let createdAt: Date
    let isOpen: Bool?
}
