//
//  PlaceDetailViewModel.swift
//  Pineat
//
//  Created by Faruk on 19.04.2026.
//

import UIKit
import CoreLocation

final class SuggestedPlaceViewModel {

    // MARK: - Properties

    let place: Place
    private let currentUserLocation: CLLocation?

    // MARK: - Init

    init(place: Place, currentUserLocation: CLLocation?) {
        self.place = place
        self.currentUserLocation = currentUserLocation
    }

    // MARK: - Texts

    var nameText: String {
        place.name
    }

    var categoryText: String {
        place.category ?? "Kategori yok"
    }

    var ratingText: String {
        guard let rating = place.rating else { return "Puan yok" }
        return String(format: "%.1f", rating)
    }

    var ratingCountText: String {
        guard let count = place.ratingCount else { return "" }
        return " • (\(count))"
    }

    var priceText: String {
        guard let price = place.price else { return "Fiyat yok" }
        return String(repeating: "₺", count: price)
    }

    var distanceText: String {
        guard let currentUserLocation else { return "—" }

        let placeLocation = CLLocation(
            latitude: place.latitude,
            longitude: place.longitude
        )

        let distance = currentUserLocation.distance(from: placeLocation)
        return DistanceFormatter.format(distance: distance)
    }

    var openStatusText: String {
        guard let isOpen = place.isOpen else { return "Durum bilinmiyor" }
        return isOpen ? "Açık" : "Kapalı"
    }

    // MARK: - UI Helpers

    var ratingValue: Double {
        place.rating ?? 0
    }

    var shouldShowRatingStar: Bool {
        place.rating != nil
    }

    var openStatusColor: UIColor {
        guard let isOpen = place.isOpen else { return .systemGray }
        return isOpen ? .systemGreen : .systemRed
    }
}
