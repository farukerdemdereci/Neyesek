//
//  UserLocation.swift
//  Pineat
//
//  Created by Faruk on 25.03.2026.
//

import CoreLocation

struct UserLocation: Codable, Equatable {
    let latitude: Double
    let longitude: Double

    var clLocation: CLLocation {
        CLLocation(latitude: latitude, longitude: longitude)
    }

    func distance(to location: CLLocation) -> Int {
        Int(clLocation.distance(from: location))
    }
}
