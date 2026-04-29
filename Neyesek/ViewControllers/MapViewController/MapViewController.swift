//
//  LocationViewController.swift
//  PinEatUIKit
//
//  Created by Faruk Dereci on 18.12.2025.
//

import UIKit
import MapKit
import CoreLocation

final class MapViewController: UIViewController {

    // MARK: - Dependencies

    private let mapVM: MapViewModel
    private let authVM: AuthViewModel

    // MARK: - Map / Location

    private let mapView = MKMapView()
    private let locationManager = CLLocationManager()

    private var currentUserLocation: UserLocation?
    private var isFirstLocationUpdate = true

    // MARK: - State

    private var selectedPlace: Place?
    private var isSelectedPlaceFavorite = false
    private var bottomCardBottomConstraint: NSLayoutConstraint?
    private var focusedFavoriteAnnotation: FavoriteAnnotation?

    // MARK: - Bottom Card UI

    private let placeStatusLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.textColor = .secondaryLabel
        return label
    }()

    private let bottomCardView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 32
        view.clipsToBounds = true
        view.backgroundColor = .white
        return view
    }()

    private let bottomCardShadowWrapper: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.40
        view.layer.shadowRadius = 9
        view.layer.shadowOffset = CGSize(width: 0, height: -3)
        return view
    }()

    private let placeNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.numberOfLines = 2
        label.textColor = .appTextColor
        return label
    }()

    private let addToFavoriteButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        let config = UIImage.SymbolConfiguration(pointSize: 26, weight: .medium)
        button.setPreferredSymbolConfiguration(config, forImageIn: .normal)
        button.setImage(UIImage(systemName: "heart"), for: .normal)
        button.tintColor = .appTextColor
        return button
    }()

    private let placeRatingTextLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .systemOrange
        return label
    }()

    private let placeRatingStarLabel: SingleStarRatingView = {
        let view = SingleStarRatingView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let placeRatingCountLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .secondaryLabel
        return label
    }()

    private let placeCategoryLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .appTextColor
        return label
    }()

    private let placeDistanceLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .secondaryLabel
        return label
    }()

    private let placePriceLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .appTextColor
        label.textAlignment = .right
        return label
    }()

    private let navigationButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Yol Tarifi Al", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        button.backgroundColor = .appAccent
        button.layer.cornerRadius = 28
        button.clipsToBounds = true
        return button
    }()

    // MARK: - Floating Buttons

    private let logoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "door.left.hand.open"), for: .normal)
        button.tintColor = .black
        button.backgroundColor = .white
        button.layer.cornerRadius = 21
        button.layer.shadowColor = UIColor.appTextColor.cgColor
        button.layer.shadowOpacity = 0.15
        button.layer.shadowRadius = 8
        button.layer.shadowOffset = CGSize(width: 0, height: 3)
        return button
    }()

    private let recenterButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "location.fill"), for: .normal)
        button.tintColor = .black
        button.backgroundColor = .white
        button.layer.cornerRadius = 21
        button.layer.shadowColor = UIColor.appTextColor.cgColor
        button.layer.shadowOpacity = 0.15
        button.layer.shadowRadius = 8
        button.layer.shadowOffset = CGSize(width: 0, height: 3)
        return button
    }()

    // MARK: - Init

    init(mapVM: MapViewModel, authVM: AuthViewModel) {
        self.mapVM = mapVM
        self.authVM = authVM
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        title = "Neyesek"

        setupMapView()
        setupLocationManager()
        setupBottomCard()
        setupActions()

        render(mapVM.fetchedPlacesState)
        updateFavoriteButtonAppearance()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        Task {
            await mapVM.fetchFavoritePlaces()

            await MainActor.run {
                self.refreshSelectedPlaceFavoriteState()

                if self.mapVM.places.isEmpty {
                    self.showFavoriteAnnotations()
                } else {
                    self.render(self.mapVM.fetchedPlacesState)
                }
            }
        }
    }
}

// MARK: - Setup

private extension MapViewController {

    func setupActions() {
        addToFavoriteButton.addTarget(self, action: #selector(addToFavoriteTapped), for: .touchUpInside)
        navigationButton.addTarget(self, action: #selector(navigationTapped), for: .touchUpInside)
        recenterButton.addTarget(self, action: #selector(recenterTapped), for: .touchUpInside)
        logoutButton.addTarget(self, action: #selector(logoutTapped), for: .touchUpInside)
    }

    func setupMapView() {
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.showsUserLocation = true
        mapView.showsCompass = false
        mapView.delegate = self

        view.addSubview(mapView)

        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 100

        handleLocationAuthorizationStatus()
    }

    func setupBottomCard() {
        view.addSubview(bottomCardShadowWrapper)
        bottomCardShadowWrapper.addSubview(bottomCardView)

        [
            placeNameLabel,
            addToFavoriteButton,
            placeRatingStarLabel,
            placeRatingTextLabel,
            placeRatingCountLabel,
            placeCategoryLabel,
            placeDistanceLabel,
            placePriceLabel,
            placeStatusLabel,
            navigationButton
        ].forEach {
            bottomCardView.addSubview($0)
        }

        view.addSubview(logoutButton)
        view.addSubview(recenterButton)

        bottomCardBottomConstraint = bottomCardShadowWrapper.bottomAnchor.constraint(
            equalTo: view.bottomAnchor,
            constant: 340
        )

        NSLayoutConstraint.activate([
            bottomCardShadowWrapper.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomCardShadowWrapper.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomCardBottomConstraint!,
            bottomCardShadowWrapper.heightAnchor.constraint(equalToConstant: 340),

            bottomCardView.topAnchor.constraint(equalTo: bottomCardShadowWrapper.topAnchor),
            bottomCardView.leadingAnchor.constraint(equalTo: bottomCardShadowWrapper.leadingAnchor),
            bottomCardView.trailingAnchor.constraint(equalTo: bottomCardShadowWrapper.trailingAnchor),
            bottomCardView.bottomAnchor.constraint(equalTo: bottomCardShadowWrapper.bottomAnchor),

            addToFavoriteButton.topAnchor.constraint(equalTo: bottomCardView.topAnchor, constant: 24),
            addToFavoriteButton.trailingAnchor.constraint(equalTo: bottomCardView.trailingAnchor, constant: -32),
            addToFavoriteButton.widthAnchor.constraint(equalToConstant: 42),
            addToFavoriteButton.heightAnchor.constraint(equalToConstant: 42),

            placeNameLabel.topAnchor.constraint(equalTo: bottomCardView.topAnchor, constant: 24),
            placeNameLabel.leadingAnchor.constraint(equalTo: bottomCardView.leadingAnchor, constant: 32),
            placeNameLabel.trailingAnchor.constraint(equalTo: addToFavoriteButton.leadingAnchor, constant: -12),

            placeRatingStarLabel.topAnchor.constraint(equalTo: placeNameLabel.bottomAnchor, constant: 16),
            placeRatingStarLabel.leadingAnchor.constraint(equalTo: bottomCardView.leadingAnchor, constant: 32),
            placeRatingStarLabel.widthAnchor.constraint(equalToConstant: 21),
            placeRatingStarLabel.heightAnchor.constraint(equalToConstant: 20),

            placeRatingTextLabel.leadingAnchor.constraint(equalTo: placeRatingStarLabel.trailingAnchor, constant: 4),
            placeRatingTextLabel.centerYAnchor.constraint(equalTo: placeRatingStarLabel.centerYAnchor),

            placeRatingCountLabel.leadingAnchor.constraint(equalTo: placeRatingTextLabel.trailingAnchor),
            placeRatingCountLabel.centerYAnchor.constraint(equalTo: placeRatingStarLabel.centerYAnchor),

            placeCategoryLabel.topAnchor.constraint(equalTo: placeRatingStarLabel.bottomAnchor, constant: 10),
            placeCategoryLabel.leadingAnchor.constraint(equalTo: bottomCardView.leadingAnchor, constant: 32),

            placeDistanceLabel.centerYAnchor.constraint(equalTo: placeCategoryLabel.centerYAnchor),
            placeDistanceLabel.leadingAnchor.constraint(equalTo: placeCategoryLabel.trailingAnchor, constant: 8),

            placeStatusLabel.topAnchor.constraint(equalTo: placeCategoryLabel.bottomAnchor, constant: 10),
            placeStatusLabel.leadingAnchor.constraint(equalTo: bottomCardView.leadingAnchor, constant: 32),
            placeStatusLabel.trailingAnchor.constraint(lessThanOrEqualTo: placePriceLabel.leadingAnchor, constant: -12),

            placePriceLabel.centerYAnchor.constraint(equalTo: placeStatusLabel.centerYAnchor),
            placePriceLabel.trailingAnchor.constraint(equalTo: bottomCardView.trailingAnchor, constant: -32),

            navigationButton.leadingAnchor.constraint(equalTo: bottomCardView.leadingAnchor, constant: 24),
            navigationButton.trailingAnchor.constraint(equalTo: bottomCardView.trailingAnchor, constant: -24),
            navigationButton.bottomAnchor.constraint(equalTo: bottomCardView.safeAreaLayoutGuide.bottomAnchor, constant: -12),
            navigationButton.heightAnchor.constraint(equalToConstant: 56),

            logoutButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            logoutButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            logoutButton.widthAnchor.constraint(equalToConstant: 42),
            logoutButton.heightAnchor.constraint(equalToConstant: 42),

            recenterButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            recenterButton.topAnchor.constraint(equalTo: logoutButton.bottomAnchor, constant: 16),
            recenterButton.widthAnchor.constraint(equalToConstant: 42),
            recenterButton.heightAnchor.constraint(equalToConstant: 42)
        ])
    }
}

// MARK: - Bottom Card

private extension MapViewController {

    func showBottomCard(place: Place) {
        selectedPlace = place
        refreshSelectedPlaceFavoriteState()

        placeNameLabel.text = place.name
        placeCategoryLabel.text = place.category ?? "Kategori yok"
        placeRatingTextLabel.text = mapVM.ratingText(for: place)

        placeRatingStarLabel.setRating(place.rating ?? 0)
        placeRatingStarLabel.isHidden = place.rating == nil

        placeRatingCountLabel.text = mapVM.ratingCountText(for: place)
        placeDistanceLabel.text = mapVM.formattedDistance(for: place)
        placePriceLabel.text = mapVM.priceText(for: place)

        let status = mapVM.openStatus(for: place)
        placeStatusLabel.text = status.text
        placeStatusLabel.textColor = status.color

        bottomCardBottomConstraint?.constant = 0

        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
    }

    func hideBottomCard() {
        selectedPlace = nil
        bottomCardBottomConstraint?.constant = 340

        UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseIn]) {
            self.view.layoutIfNeeded()
        }
    }
}

// MARK: - Favorite UI

private extension MapViewController {

    func updateFavoriteButtonAppearance() {
        let imageName = isSelectedPlaceFavorite ? "heart.fill" : "heart"
        let config = UIImage.SymbolConfiguration(pointSize: 26, weight: .medium)

        addToFavoriteButton.setImage(UIImage(systemName: imageName), for: .normal)
        addToFavoriteButton.setPreferredSymbolConfiguration(config, forImageIn: .normal)
        addToFavoriteButton.tintColor = isSelectedPlaceFavorite ? .appAccent : .appTextColor
    }

    func refreshSelectedPlaceFavoriteState() {
        if let selectedPlace {
            isSelectedPlaceFavorite = mapVM.isFavorite(placeId: selectedPlace.id)
        } else {
            isSelectedPlaceFavorite = false
        }

        updateFavoriteButtonAppearance()
    }
}

// MARK: - Map Rendering

private extension MapViewController {

    func showAnnotations(_ places: [Place]) {
        focusedFavoriteAnnotation = nil

        let oldAnnotations = mapView.annotations.filter {
            !($0 is MKUserLocation)
        }

        mapView.removeAnnotations(oldAnnotations)

        let annotations = places.map {
            PlaceAnnotation(
                place: $0,
                isFavorite: mapVM.isFavorite(placeId: $0.id)
            )
        }

        mapView.addAnnotations(annotations)
    }

    func showFavoriteAnnotations() {
        guard mapVM.places.isEmpty else { return }

        let oldAnnotations = mapView.annotations.filter {
            !($0 is MKUserLocation)
        }

        mapView.removeAnnotations(oldAnnotations)

        let favoriteAnnotations = mapVM.favoritePlaces.map {
            FavoriteAnnotation(favorite: $0)
        }

        mapView.addAnnotations(favoriteAnnotations)
    }

    func render(_ state: ViewState<[Place]>) {
        switch state {
        case .idle:
            hideLoading()

        case .loading:
            showLoading()

        case .success(let places):
            hideLoading()
            showAnnotations(places)

        case .empty:
            hideLoading()
            showAnnotations([])
            hideBottomCard()

        case .error(let error):
            hideLoading()
            showAlert(title: "Hata", message: error.localizedDescription)
        }
    }
}

// MARK: - Actions

private extension MapViewController {

    @objc
    func addToFavoriteTapped() {
        guard let selectedPlace else { return }

        Task {
            if isSelectedPlaceFavorite {
                if let favorite = mapVM.favoritePlaces.first(where: { $0.placeId == selectedPlace.id }) {
                    await mapVM.deleteFavoritePlace(id: favorite.id)
                    await mapVM.fetchFavoritePlaces()

                    await MainActor.run {
                        self.isSelectedPlaceFavorite = false
                        self.updateFavoriteButtonAppearance()
                        self.mapVM.resetDeleteFavoritePlaceState()
                    }
                }
            } else {
                await mapVM.saveFavoritePlace(
                    name: selectedPlace.name,
                    latitude: selectedPlace.latitude,
                    longitude: selectedPlace.longitude,
                    placeId: selectedPlace.id,
                    category: selectedPlace.category ?? "Kategori yok",
                    price: selectedPlace.price,
                    rating: selectedPlace.rating,
                    ratingCount: selectedPlace.ratingCount
                )

                await mapVM.fetchFavoritePlaces()

                await MainActor.run {
                    switch self.mapVM.saveFavoritePlaceState {
                    case .success:
                        self.isSelectedPlaceFavorite = true
                        self.updateFavoriteButtonAppearance()
                        self.mapVM.resetFavoriteSaveState()

                    case .error(let error):
                        self.showAlert(title: "Hata", message: error.localizedDescription)
                        self.mapVM.resetFavoriteSaveState()

                    default:
                        break
                    }
                }
            }
        }
    }

    @objc
    func navigationTapped() {
        guard let selectedPlace else { return }

        openMaps(
            title: selectedPlace.name,
            latitude: selectedPlace.latitude,
            longitude: selectedPlace.longitude
        )
    }

    @objc
    func logoutTapped() {
        let alert = UIAlertController(
            title: "Çıkış Yap",
            message: "Hesabınızdan çıkmak istiyor musunuz?",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "İptal", style: .cancel))

        alert.addAction(UIAlertAction(title: "Çıkış Yap", style: .destructive) { _ in
            Task {
                await self.authVM.signOut()

                await MainActor.run {
                    if let scene = self.view.window?.windowScene,
                       let sceneDelegate = scene.delegate as? SceneDelegate {
                        sceneDelegate.resetToLogin()
                    }
                }
            }
        })

        present(alert, animated: true)
    }

    @objc
    func recenterTapped() {
        guard let currentUserLocation else { return }

        hideBottomCard()

        let coordinate = CLLocationCoordinate2D(
            latitude: currentUserLocation.latitude,
            longitude: currentUserLocation.longitude
        )

        let region = MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )

        mapView.setRegion(region, animated: true)
    }
}

// MARK: - Helpers

private extension MapViewController {

    func openMaps(title: String, latitude: Double, longitude: Double) {
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate))
        mapItem.name = title

        mapItem.openInMaps(launchOptions: [
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
        ])
    }

    func handleLocationAuthorizationStatus() {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()

        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()

        case .denied, .restricted:
            showAlert(
                title: "Konum İzni Kapalı",
                message: "Yakındaki mekanları gösterebilmek için Ayarlar’dan konum izni vermelisiniz."
            )

        @unknown default:
            break
        }
    }
}

// MARK: - MKMapViewDelegate / CLLocationManagerDelegate

extension MapViewController: MKMapViewDelegate, CLLocationManagerDelegate {

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        handleLocationAuthorizationStatus()
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }

        if annotation is FavoriteAnnotation {
            let identifier = "FavoriteMarker"

            let annotationView = mapView.dequeueReusableAnnotationView(
                withIdentifier: identifier
            ) as? MKMarkerAnnotationView
                ?? MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)

            annotationView.annotation = annotation
            annotationView.canShowCallout = false
            annotationView.markerTintColor = .systemRed
            annotationView.glyphImage = UIImage(systemName: "heart.fill")

            return annotationView
        }

        guard let placeAnnotation = annotation as? PlaceAnnotation else {
            return nil
        }

        let identifier = "PlaceMarker"

        let annotationView = mapView.dequeueReusableAnnotationView(
            withIdentifier: identifier
        ) as? MKMarkerAnnotationView
            ?? MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)

        annotationView.annotation = annotation
        annotationView.canShowCallout = false

        if placeAnnotation.isFavorite {
            annotationView.markerTintColor = .systemRed
            annotationView.glyphImage = UIImage(systemName: "heart.fill")
        } else {
            annotationView.markerTintColor = .appAccent
            annotationView.glyphImage = nil
        }

        return annotationView
    }

    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard !(view.annotation is MKUserLocation) else { return }

        if let favoriteAnnotation = view.annotation as? FavoriteAnnotation {
            guard let favorite = mapVM.favoritePlaces.first(where: {
                $0.latitude == favoriteAnnotation.coordinate.latitude &&
                $0.longitude == favoriteAnnotation.coordinate.longitude
            }) else { return }

            let place = Place(
                id: favorite.placeId,
                name: favorite.name,
                category: favorite.category,
                latitude: favorite.latitude,
                longitude: favorite.longitude,
                price: favorite.price,
                rating: favorite.rating,
                ratingCount: favorite.ratingCount,
                isOpen: nil
            )

            showBottomCard(place: place)

            Task {
                await mapVM.fetchFavoriteOpenStatus(for: favorite)

                await MainActor.run {
                    self.placeStatusLabel.text = self.mapVM.favoriteStatusText
                    self.placeStatusLabel.textColor = self.mapVM.favoriteStatusColor

                    if self.mapVM.isRequestLimitReached,
                       self.mapVM.favoriteStatusText == "Limit doldu" {
                        self.showAlert(
                            title: "Günlük Hak Doldu",
                            message: "Günlük hakkınız bittiği için açık/kapalı durumu gösterilememektedir."
                        )
                    }
                }
            }

            return
        }

        guard let placeAnnotation = view.annotation as? PlaceAnnotation else { return }
        showBottomCard(place: placeAnnotation.place)
    }

    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        hideBottomCard()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let lastLocation = locations.last else { return }

        let userLocation = UserLocation(
            latitude: lastLocation.coordinate.latitude,
            longitude: lastLocation.coordinate.longitude
        )

        currentUserLocation = userLocation
        mapVM.updateUserLocation(lastLocation)

        if isFirstLocationUpdate {
            mapView.setRegion(
                MKCoordinateRegion(
                    center: lastLocation.coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                ),
                animated: true
            )

            isFirstLocationUpdate = false
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        showAlert(title: "Konum Hatası", message: error.localizedDescription)
    }
}

// MARK: - External Actions

extension MapViewController {

    func focusOnFavoriteLocation(_ favorite: FavoritePlace) {
        hideBottomCard()

        if let focusedFavoriteAnnotation {
            mapView.removeAnnotation(focusedFavoriteAnnotation)
        }

        let annotation = FavoriteAnnotation(favorite: favorite)
        focusedFavoriteAnnotation = annotation
        mapView.addAnnotation(annotation)

        let coordinate = CLLocationCoordinate2D(
            latitude: favorite.latitude,
            longitude: favorite.longitude
        )

        let region = MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )

        mapView.setRegion(region, animated: true)
    }
}
