//
//  PlaceAnnotation.swift
//  Pineat
//
//  Created by Faruk on 18.04.2026.
//

import Foundation
import MapKit

final class PlaceAnnotation: NSObject, MKAnnotation {

    let place: Place
    let isFavorite: Bool

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(
            latitude: place.latitude,
            longitude: place.longitude
        )
    }

    var title: String? {
        place.name
    }

    var subtitle: String? {
        place.category
    }

    init(place: Place, isFavorite: Bool) {
        self.place = place
        self.isFavorite = isFavorite
    }
}
