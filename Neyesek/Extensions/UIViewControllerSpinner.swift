//
//  UIViewControllerSpinner.swift
//  Pineat
//
//  Created by Faruk on 25.03.2026.
//

import Foundation
import UIKit

private var _loaderKey: UInt8 = 0

extension UIViewController {

    private var loader: UIView? {
        get { objc_getAssociatedObject(self, &_loaderKey) as? UIView }
        set { objc_setAssociatedObject(self, &_loaderKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }

    func showLoading() {
        DispatchQueue.main.async {
            guard self.loader == nil else { return }

            let container = UIView()
            container.translatesAutoresizingMaskIntoConstraints = false
            container.backgroundColor = UIColor.black.withAlphaComponent(0.1)

            let indicator = UIActivityIndicatorView(style: .large)
            indicator.translatesAutoresizingMaskIntoConstraints = false
            indicator.startAnimating()

            container.addSubview(indicator)
            self.view.addSubview(container)

            NSLayoutConstraint.activate([
                container.topAnchor.constraint(equalTo: self.view.topAnchor),
                container.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                container.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
                container.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),

                indicator.centerXAnchor.constraint(equalTo: container.centerXAnchor),
                indicator.centerYAnchor.constraint(equalTo: container.centerYAnchor)
            ])

            self.loader = container
        }
    }

    func hideLoading() {
        DispatchQueue.main.async {
            self.loader?.removeFromSuperview()
            self.loader = nil
        }
    }
}
