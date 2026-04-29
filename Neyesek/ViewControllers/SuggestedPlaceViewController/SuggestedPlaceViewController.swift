//
//  PlaceDetailViewController.swift
//  Pineat
//
//  Created by Faruk on 18.04.2026.
//

import UIKit
import MapKit
import CoreLocation

final class SuggestedPlaceViewController: UIViewController {

    // MARK: - Dependencies

    private let vm: SuggestedPlaceViewModel
    
    // MARK: - Properties
    
    var onSuggestAnother: (() -> Void)?

    // MARK: - UI Components

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 26, weight: .bold)
        label.textColor = .appTextColor
        label.numberOfLines = 2
        return label
    }()

    private let categoryLabel = SuggestedPlaceViewController.makeInlineLabel(
        size: 18,
        weight: .semibold,
        color: .appTextColor
    )

    private let ratingStarLabel: SingleStarRatingView = {
        let view = SingleStarRatingView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let ratingTextLabel = SuggestedPlaceViewController.makeInlineLabel(
        size: 18,
        weight: .semibold,
        color: .systemOrange
    )

    private let ratingCountLabel = SuggestedPlaceViewController.makeInlineLabel(
        size: 18,
        weight: .medium,
        color: .secondaryLabel
    )

    private let distanceLabel = SuggestedPlaceViewController.makeInlineLabel(
        size: 18,
        weight: .medium,
        color: .appTextColor
    )

    private let priceLabel = SuggestedPlaceViewController.makeInlineLabel(
        size: 18,
        weight: .medium,
        color: .appTextColor
    )

    private let statusLabel = SuggestedPlaceViewController.makeInlineLabel(
        size: 18,
        weight: .bold,
        color: .systemGray
    )

    private let directionsButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Yol Tarifi Al", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .appAccent
        button.layer.cornerRadius = 28
        button.clipsToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        return button
    }()

    private let suggestAnotherButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "shuffle"), for: .normal)
        button.tintColor = .appTextColor
        button.backgroundColor = .appSecondary
        return button
    }()

    private let closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Kapat", for: .normal)
        button.setTitleColor(.appTextColor, for: .normal)
        button.backgroundColor = .appSecondary
        button.layer.borderWidth = 1.2
        button.layer.borderColor = UIColor.appTextColor.cgColor
        button.layer.cornerRadius = 28
        button.clipsToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        return button
    }()

    // MARK: - Init

    init(vm: SuggestedPlaceViewModel) {
        self.vm = vm
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        setupUI()
        setupActions()
        configureUI()
    }
}

// MARK: - Setup UI

private extension SuggestedPlaceViewController {

    func setupUI() {
        setupHierarchy()
        setupConstraints()
    }

    func setupHierarchy() {
        [
            titleLabel,
            categoryLabel,
            ratingStarLabel,
            ratingTextLabel,
            ratingCountLabel,
            distanceLabel,
            priceLabel,
            statusLabel,
            directionsButton,
            suggestAnotherButton,
            closeButton
        ].forEach {
            view.addSubview($0)
        }
    }

    func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 36),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            titleLabel.trailingAnchor.constraint(equalTo: suggestAnotherButton.leadingAnchor, constant: -8),

            categoryLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            categoryLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            categoryLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -32),

            ratingStarLabel.topAnchor.constraint(equalTo: categoryLabel.bottomAnchor, constant: 16),
            ratingStarLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            ratingStarLabel.widthAnchor.constraint(equalToConstant: 22),
            ratingStarLabel.heightAnchor.constraint(equalToConstant: 21),

            ratingTextLabel.leadingAnchor.constraint(equalTo: ratingStarLabel.trailingAnchor, constant: 4),
            ratingTextLabel.centerYAnchor.constraint(equalTo: ratingStarLabel.centerYAnchor),

            ratingCountLabel.leadingAnchor.constraint(equalTo: ratingTextLabel.trailingAnchor),
            ratingCountLabel.centerYAnchor.constraint(equalTo: ratingStarLabel.centerYAnchor),
            ratingCountLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -32),

            distanceLabel.topAnchor.constraint(equalTo: ratingStarLabel.bottomAnchor, constant: 10),
            distanceLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),

            statusLabel.topAnchor.constraint(equalTo: distanceLabel.bottomAnchor, constant: 10),
            statusLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            statusLabel.trailingAnchor.constraint(lessThanOrEqualTo: priceLabel.leadingAnchor, constant: -12),

            priceLabel.centerYAnchor.constraint(equalTo: statusLabel.centerYAnchor),
            priceLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),

            directionsButton.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 30),
            directionsButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            directionsButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            directionsButton.heightAnchor.constraint(equalToConstant: 60),

            suggestAnotherButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 36),
            suggestAnotherButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            suggestAnotherButton.heightAnchor.constraint(equalToConstant: 32),
            suggestAnotherButton.widthAnchor.constraint(equalToConstant: 32),

            closeButton.topAnchor.constraint(equalTo: directionsButton.bottomAnchor, constant: 16),
            closeButton.leadingAnchor.constraint(equalTo: directionsButton.leadingAnchor),
            closeButton.trailingAnchor.constraint(equalTo: directionsButton.trailingAnchor),
            closeButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }

    func setupActions() {
        directionsButton.addTarget(self, action: #selector(directionsTapped), for: .touchUpInside)
        suggestAnotherButton.addTarget(self, action: #selector(suggestAnotherTapped), for: .touchUpInside)
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
    }

    func configureUI() {
        titleLabel.text = vm.nameText
        categoryLabel.text = vm.categoryText

        ratingTextLabel.text = vm.ratingText
        ratingCountLabel.text = vm.ratingCountText

        ratingStarLabel.setRating(vm.ratingValue)
        ratingStarLabel.isHidden = !vm.shouldShowRatingStar

        distanceLabel.text = vm.distanceText
        priceLabel.text = vm.priceText

        statusLabel.text = vm.openStatusText
        statusLabel.textColor = vm.openStatusColor
    }
}

// MARK: - Actions

private extension SuggestedPlaceViewController {

    @objc
    func directionsTapped() {
        let coordinate = CLLocationCoordinate2D(
            latitude: vm.place.latitude,
            longitude: vm.place.longitude
        )

        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate))
        mapItem.name = vm.nameText
        mapItem.openInMaps(launchOptions: [
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
        ])
    }

    @objc
    func suggestAnotherTapped() {
        dismiss(animated: true) {
            self.onSuggestAnother?()
        }
    }

    @objc
    func closeTapped() {
        dismiss(animated: true)
    }
}

// MARK: - UI Helpers

private extension SuggestedPlaceViewController {

    static func makeInlineLabel(
        size: CGFloat,
        weight: UIFont.Weight,
        color: UIColor
    ) -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: size, weight: weight)
        label.textColor = color
        label.numberOfLines = 1
        return label
    }
}
