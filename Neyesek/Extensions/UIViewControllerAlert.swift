//
//  UIViewControllerAlert.swift
//  Pineat
//
//  Created by Faruk Dereci on 8.02.2026.
//

import Foundation
import UIKit

extension UIViewController {

    func showAlert(title: String = "Hata", message: String) {
        guard presentedViewController == nil else { return }

        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Tamam", style: .default))

        present(alert, animated: true)
    }
}
