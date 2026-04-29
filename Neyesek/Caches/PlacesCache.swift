//
//  PlaceCache.swift
//  Pineat
//
//  Created by Faruk on 27.04.2026.
//

import Foundation

final class PlacesCache {

    static let shared = PlacesCache()

    private let keyPrefix = "places_cache_"
    private let ttl: TimeInterval = 10 * 60

    private init() {}

    func get(userLocation: UserLocation, filter: PlaceFilter) -> [Place]? {
        let key = cacheKey(userLocation: userLocation, filter: filter)

        guard let data = UserDefaults.standard.data(forKey: key),
              let cached = try? JSONDecoder().decode(CachedPlaces.self, from: data)
        else {
            return nil
        }

        let isExpired = Date().timeIntervalSince(cached.createdAt) >= ttl

        if isExpired {
            UserDefaults.standard.removeObject(forKey: key)
            return nil
        }

        return cached.places
    }

    func save(places: [Place], userLocation: UserLocation, filter: PlaceFilter) {
        let key = cacheKey(userLocation: userLocation, filter: filter)
        let cached = CachedPlaces(createdAt: Date(), places: places)

        guard let data = try? JSONEncoder().encode(cached) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }

    private func cacheKey(userLocation: UserLocation, filter: PlaceFilter) -> String {
        let latBucket = Int(userLocation.latitude * 1000)
        let lngBucket = Int(userLocation.longitude * 1000)

        return keyPrefix +
        "\(latBucket)_" +
        "\(lngBucket)_" +
        "\(filter.category ?? "none")_" +
        "\(filter.radius ?? 0)_" +
        "\(filter.minRating ?? 0)_" +
        "\(filter.price ?? 0)_" +
        "\(filter.openNow == true)"
    }
}

private struct CachedPlaces: Codable {
    let createdAt: Date
    let places: [Place]
}
