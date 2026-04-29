//
//  DistanceFormatter.swift
//  Pineat
//
//  Created by Faruk on 20.04.2026.
//

import Foundation
import CoreLocation

enum DistanceFormatter {
    
    static func format(distance: CLLocationDistance?) -> String {
        guard let distance else { return "—" }

        if distance < 1000 {
            return "\(Int(distance)) m"
        } else {
            return String(format: "%.1f km", distance / 1000)
        }
    }
}
