//
//  SingleStarRatingView.swift
//  Pineat
//
//  Created by Faruk on 1.04.2026.
//

import UIKit

final class SingleStarRatingView: UIView {

    private let backgroundStar = UIImageView()
    private let fillStar = UIImageView()
    
    private let maskLayer = CALayer()

    private var rating: Double = 0

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        backgroundStar.image = UIImage(systemName: "star")
        backgroundStar.tintColor = .systemGray4
        backgroundStar.translatesAutoresizingMaskIntoConstraints = false
        
        fillStar.image = UIImage(systemName: "star.fill")
        fillStar.tintColor = .systemOrange
        fillStar.translatesAutoresizingMaskIntoConstraints = false

        addSubview(backgroundStar)
        addSubview(fillStar)

        NSLayoutConstraint.activate([
            backgroundStar.topAnchor.constraint(equalTo: topAnchor),
            backgroundStar.leadingAnchor.constraint(equalTo: leadingAnchor),
            backgroundStar.trailingAnchor.constraint(equalTo: trailingAnchor),
            backgroundStar.bottomAnchor.constraint(equalTo: bottomAnchor),

            fillStar.topAnchor.constraint(equalTo: topAnchor),
            fillStar.leadingAnchor.constraint(equalTo: leadingAnchor),
            fillStar.trailingAnchor.constraint(equalTo: trailingAnchor),
            fillStar.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        fillStar.layer.mask = maskLayer
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateMask()
    }

    func setRating(_ rating: Double) {
        self.rating = rating
        setNeedsLayout()
    }

    private func updateMask() {
        let clamped = max(0, min(rating, 5))
        let percentage = CGFloat(clamped / 5.0)

        let width = bounds.width * percentage

        maskLayer.frame = CGRect(
            x: 0,
            y: 0,
            width: width,
            height: bounds.height
        )
        maskLayer.backgroundColor = UIColor.black.cgColor
    }
}
