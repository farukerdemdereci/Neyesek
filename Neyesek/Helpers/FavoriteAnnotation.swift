//
//  FavoriteAnnotation.swift
//  Pineat
//
//  Created by Faruk on 26.04.2026.
//

import Foundation
import MapKit

final class FavoriteAnnotation: NSObject, MKAnnotation {

    let favorite: FavoritePlace

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(
            latitude: favorite.latitude,
            longitude: favorite.longitude
        )
    }

    var title: String? { favorite.name }
    var subtitle: String? { favorite.category }

    init(favorite: FavoritePlace) {
        self.favorite = favorite
    }
}
