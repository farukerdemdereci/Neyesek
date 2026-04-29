//
//  UIViewControllerColors.swift
//  Pineat
//
//  Created by Faruk on 6.04.2026.
//

import Foundation
import UIKit

extension UIColor {

    static let appAccent = UIColor(hex: "#F14647")
    static let appBackground = UIColor(hex: "#FFFFFF")
    static let appSecondary = UIColor(hex: "#F7F7F7")
    static let appTextColor = UIColor(hex: "#1F272D")

    // MARK: - Hex Initializer
    convenience init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0

        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else {
            self.init(white: 0.0, alpha: 1.0) // fallback
            return
        }

        let r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let b = CGFloat(rgb & 0x0000FF) / 255.0

        self.init(red: r, green: g, blue: b, alpha: 1.0)
    }
}
