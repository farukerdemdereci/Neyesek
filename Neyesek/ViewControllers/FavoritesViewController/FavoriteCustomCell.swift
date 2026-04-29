//
//  ListCustomCell.swift
//  PinEatUIKit
//
//  Created by Faruk Dereci on 24.12.2025.
//

import UIKit

final class FavoritePlacesCustomCell: UITableViewCell {
    
    // MARK: - Static Properties
    
    static let identifier = "FavoritePlacesCustomCell"

    // MARK: - UI Components

    private let placeNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.numberOfLines = 2
        label.lineBreakMode = .byTruncatingTail
        label.textColor = .appTextColor
        return label
    }()

    private let placeRatingStarLabel: SingleStarRatingView = {
        let view = SingleStarRatingView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let placeRatingTextLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .systemOrange
        return label
    }()
    
    private let placeRatingCountLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .secondaryLabel
        return label
    }()

    private let placeCategoryLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .appTextColor
        label.numberOfLines = 1
        return label
    }()

    private let placeDistanceLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .secondaryLabel
        label.numberOfLines = 1
        return label
    }()
    
    private let placePriceLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .appTextColor
        label.textAlignment = .center
        label.numberOfLines = 1
        return label
    }()
    
    private let separatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.systemGray4
        return view
    }()

    // MARK: - Init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle = .none
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle / Overrides

    override func prepareForReuse() {
        super.prepareForReuse()
        placeNameLabel.text = nil
        placeRatingTextLabel.text = nil
        placeRatingCountLabel.text = nil
        placeRatingStarLabel.setRating(0)
        placeRatingStarLabel.isHidden = false
        placeCategoryLabel.text = nil
        placeDistanceLabel.text = nil
        placePriceLabel.text = nil
    }

    // MARK: - Configuration

    func configure(
        name: String,
        rating: Double? = nil,
        ratingCount: Int? = nil,
        category: String? = nil,
        distance: String? = nil,
        price: Int? = nil
    ) {
        placeNameLabel.text = name

        if let rating {
            placeRatingStarLabel.isHidden = false
            placeRatingStarLabel.setRating(rating)
            placeRatingTextLabel.text = String(format: "%.1f", rating)
            placeRatingCountLabel.text = ratingCount.map { " • (\($0))" } ?? ""
        } else {
            placeRatingStarLabel.isHidden = true
            placeRatingStarLabel.setRating(0)
            placeRatingTextLabel.text = "Puan yok"
            placeRatingCountLabel.text = ""
        }
        
        placeCategoryLabel.text = category ?? "Kategori yok"
        placeDistanceLabel.text = distance ?? "Mesafe yok"
        placePriceLabel.text = priceText(price)
    }
}

// MARK: - Setup UI

private extension FavoritePlacesCustomCell {
    
    func setupUI() {
        setupHierarchy()
        setupConstraints()
    }

    func setupHierarchy() {
        contentView.addSubview(placeNameLabel)
        contentView.addSubview(placeRatingStarLabel)
        contentView.addSubview(placeRatingTextLabel)
        contentView.addSubview(placeRatingCountLabel)
        contentView.addSubview(placeCategoryLabel)
        contentView.addSubview(placeDistanceLabel)
        contentView.addSubview(placePriceLabel)
        contentView.addSubview(separatorView)
    }

    func setupConstraints() {
        NSLayoutConstraint.activate([
            placeNameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            placeNameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            placeNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            
            placeRatingStarLabel.topAnchor.constraint(equalTo: placeNameLabel.bottomAnchor, constant: 10),
            placeRatingStarLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            placeRatingStarLabel.widthAnchor.constraint(equalToConstant: 17),
            placeRatingStarLabel.heightAnchor.constraint(equalToConstant: 16),

            placeRatingTextLabel.leadingAnchor.constraint(equalTo: placeRatingStarLabel.trailingAnchor, constant: 2),
            placeRatingTextLabel.centerYAnchor.constraint(equalTo: placeRatingStarLabel.centerYAnchor),
            
            placeRatingCountLabel.centerYAnchor.constraint(equalTo: placeRatingStarLabel.centerYAnchor),
            placeRatingCountLabel.leadingAnchor.constraint(equalTo: placeRatingTextLabel.trailingAnchor),
            placeRatingCountLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -24),

            placeCategoryLabel.topAnchor.constraint(equalTo: placeRatingStarLabel.bottomAnchor, constant: 10),
            placeCategoryLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),

            placeDistanceLabel.centerYAnchor.constraint(equalTo: placeCategoryLabel.centerYAnchor),
            placeDistanceLabel.leadingAnchor.constraint(equalTo: placeCategoryLabel.trailingAnchor, constant: 8),

            placePriceLabel.centerYAnchor.constraint(equalTo: placeCategoryLabel.centerYAnchor),
            placePriceLabel.leadingAnchor.constraint(greaterThanOrEqualTo: placeDistanceLabel.trailingAnchor, constant: 12),
            placePriceLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),

            separatorView.heightAnchor.constraint(equalToConstant: 0.5),
            separatorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            separatorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            separatorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            placeCategoryLabel.bottomAnchor.constraint(equalTo: separatorView.topAnchor, constant: -12)
        ])
    }
}

// MARK: - Helpers

private extension FavoritePlacesCustomCell {
    
    func priceText(_ price: Int?) -> String {
        guard let price else { return "Fiyat yok" }
        return String(repeating: "₺", count: price)
    }
}
