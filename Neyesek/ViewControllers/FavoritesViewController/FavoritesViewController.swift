//
//  FavoritesViewController.swift
//  PinEatUIKit
//
//  Created by Faruk Dereci on 18.12.2025.
//

import UIKit
import CoreLocation

final class FavoritesViewController: UIViewController {

    // MARK: - Dependencies

    private let favoriteVM: FavoritesViewModel
    private let locationManager = CLLocationManager()

    // MARK: - State

    private var data: [FavoritePlace] = []
    private var searchContainerBottomConstraint: NSLayoutConstraint?
    private var lastDistanceRefreshDate: Date?
    private var lastDistanceLocation: CLLocation?

    // MARK: - UI Components

    private let backgroundView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .appAccent
        return view
    }()

    private let containerShadowWrapper: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.40
        view.layer.shadowRadius = 9
        view.layer.shadowOffset = CGSize(width: 0, height: -3)
        return view
    }()

    private let contentContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 32
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.clipsToBounds = true
        return view
    }()

    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(
            FavoritePlacesCustomCell.self,
            forCellReuseIdentifier: FavoritePlacesCustomCell.identifier
        )
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 140
        return tableView
    }()

    private let emptyImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "neyesek_logo_mini"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Henüz bir mekan eklemediniz."
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        return label
    }()

    private lazy var emptyStateView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        view.addSubview(emptyImageView)
        view.addSubview(emptyStateLabel)

        NSLayoutConstraint.activate([
            emptyImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -96),
            emptyImageView.widthAnchor.constraint(equalToConstant: 72),
            emptyImageView.heightAnchor.constraint(equalToConstant: 72),

            emptyStateLabel.topAnchor.constraint(equalTo: emptyImageView.bottomAnchor, constant: 16),
            emptyStateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            emptyStateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32)
        ])
        return view
    }()

    private let searchContainer: UIVisualEffectView = {
        let blur = UIBlurEffect(style: .systemUltraThinMaterial)
        let view = UIVisualEffectView(effect: blur)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 18
        view.clipsToBounds = true
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.white.withAlphaComponent(0.18).cgColor
        return view
    }()

    private let searchOverlayView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.white.withAlphaComponent(0.15)
        view.isUserInteractionEnabled = false
        return view
    }()

    private let searchField: UITextField = {
        let textfield = UITextField()
        textfield.translatesAutoresizingMaskIntoConstraints = false
        textfield.font = .systemFont(ofSize: 16, weight: .semibold)
        textfield.textColor = .label
        textfield.backgroundColor = .clear
        textfield.returnKeyType = .done
        textfield.attributedPlaceholder = NSAttributedString(
            string: "Mekan ara",
            attributes: [.foregroundColor: UIColor.secondaryLabel]
        )

        let icon = UIImageView(image: UIImage(systemName: "magnifyingglass"))
        icon.tintColor = .secondaryLabel
        icon.frame = CGRect(x: 0, y: 0, width: 32, height: 20)
        icon.contentMode = .center

        let left = UIView(frame: CGRect(x: 0, y: 0, width: 36, height: 20))
        left.addSubview(icon)
        textfield.leftView = left
        textfield.leftViewMode = .always
        return textfield
    }()

    // MARK: - Init

    init(favoriteVM: FavoritesViewModel) {
        self.favoriteVM = favoriteVM
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground

        setupUI()
        setupNav()
        setupLocation()
        setupKeyboardObservers()
        setupActions()

        render(favoriteVM.fetchedFavoritePlacesState)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchFavoritePlaces()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - Setup UI

private extension FavoritesViewController {

    func setupUI() {
        setupHierarchy()
        setupConstraints()

        tableView.delegate = self
        tableView.dataSource = self
        tableView.contentInset.top = 8
        tableView.contentInset.bottom = 110
        tableView.scrollIndicatorInsets.bottom = 110

        searchField.delegate = self
    }

    func setupHierarchy() {
        view.addSubview(backgroundView)
        view.addSubview(containerShadowWrapper)
        view.addSubview(searchContainer)

        containerShadowWrapper.addSubview(contentContainerView)
        contentContainerView.addSubview(tableView)
        contentContainerView.addSubview(emptyStateView)

        searchContainer.contentView.addSubview(searchOverlayView)
        searchContainer.contentView.addSubview(searchField)
    }

    func setupConstraints() {
        searchContainerBottomConstraint = searchContainer.bottomAnchor.constraint(
            equalTo: view.safeAreaLayoutGuide.bottomAnchor,
            constant: -16
        )

        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            containerShadowWrapper.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            containerShadowWrapper.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerShadowWrapper.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerShadowWrapper.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentContainerView.topAnchor.constraint(equalTo: containerShadowWrapper.topAnchor),
            contentContainerView.leadingAnchor.constraint(equalTo: containerShadowWrapper.leadingAnchor),
            contentContainerView.trailingAnchor.constraint(equalTo: containerShadowWrapper.trailingAnchor),
            contentContainerView.bottomAnchor.constraint(equalTo: containerShadowWrapper.bottomAnchor),

            tableView.topAnchor.constraint(equalTo: contentContainerView.topAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: contentContainerView.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: contentContainerView.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: contentContainerView.bottomAnchor),

            emptyStateView.topAnchor.constraint(equalTo: contentContainerView.topAnchor),
            emptyStateView.leadingAnchor.constraint(equalTo: contentContainerView.leadingAnchor),
            emptyStateView.trailingAnchor.constraint(equalTo: contentContainerView.trailingAnchor),
            emptyStateView.bottomAnchor.constraint(equalTo: contentContainerView.bottomAnchor),

            searchContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            searchContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            searchContainerBottomConstraint!,
            searchContainer.heightAnchor.constraint(equalToConstant: 52),

            searchOverlayView.topAnchor.constraint(equalTo: searchContainer.contentView.topAnchor),
            searchOverlayView.leadingAnchor.constraint(equalTo: searchContainer.contentView.leadingAnchor),
            searchOverlayView.trailingAnchor.constraint(equalTo: searchContainer.contentView.trailingAnchor),
            searchOverlayView.bottomAnchor.constraint(equalTo: searchContainer.contentView.bottomAnchor),

            searchField.leadingAnchor.constraint(equalTo: searchContainer.contentView.leadingAnchor, constant: 8),
            searchField.trailingAnchor.constraint(equalTo: searchContainer.contentView.trailingAnchor, constant: -8),
            searchField.topAnchor.constraint(equalTo: searchContainer.contentView.topAnchor),
            searchField.bottomAnchor.constraint(equalTo: searchContainer.contentView.bottomAnchor)
        ])
    }

    func setupNav() {
        title = "Favoriler"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always

        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]

        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        navigationController?.navigationBar.tintColor = .white
    }

    func setupLocation() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.distanceFilter = 100
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    func setupActions() {
        searchField.addTarget(self, action: #selector(searchChanged), for: .editingChanged)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
}

// MARK: - Actions

private extension FavoritesViewController {

    func fetchFavoritePlaces() {
        Task {
            await favoriteVM.fetchFavoritePlaces()

            await MainActor.run {
                self.render(self.favoriteVM.fetchedFavoritePlacesState)
            }
        }
    }

    @objc func searchChanged() {
        let text = (searchField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        favoriteVM.filterContentForSearchText(text)
        render(favoriteVM.fetchedFavoritePlacesState)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    @objc func keyboardWillShow(notification: NSNotification) {
        guard
            let keyboardFrameValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue,
            let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
            let curveRawValue = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt
        else { return }

        let keyboardFrame = keyboardFrameValue.cgRectValue
        let keyboardFrameInView = view.convert(keyboardFrame, from: nil)

        let overlapHeight = max(0, view.bounds.maxY - keyboardFrameInView.minY)
        let bottomInset = view.safeAreaInsets.bottom
        let targetOffset = max(8, overlapHeight - bottomInset + 12)

        searchContainerBottomConstraint?.constant = -targetOffset

        UIView.animate(
            withDuration: duration,
            delay: 0,
            options: UIView.AnimationOptions(rawValue: curveRawValue << 16),
            animations: {
                self.view.layoutIfNeeded()
            }
        )
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        guard
            let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
            let curveRawValue = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt
        else { return }

        searchContainerBottomConstraint?.constant = -12

        UIView.animate(
            withDuration: duration,
            delay: 0,
            options: UIView.AnimationOptions(rawValue: curveRawValue << 16),
            animations: {
                self.view.layoutIfNeeded()
            }
        )
    }

    func shouldRefreshDistance(for newLocation: CLLocation) -> Bool {
        let now = Date()

        let passedTimeEnough: Bool = {
            guard let lastDate = lastDistanceRefreshDate else { return true }
            return now.timeIntervalSince(lastDate) >= 10
        }()

        let movedEnough: Bool = {
            guard let lastLocation = lastDistanceLocation else { return true }
            return newLocation.distance(from: lastLocation) >= 100
        }()

        guard passedTimeEnough || movedEnough else { return false }

        lastDistanceRefreshDate = now
        lastDistanceLocation = newLocation
        return true
    }
}

// MARK: - UITableViewDataSource & Delegate

extension FavoritesViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        data.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: FavoritePlacesCustomCell.identifier,
            for: indexPath
        ) as? FavoritePlacesCustomCell else {
            return UITableViewCell()
        }

        let place = data[indexPath.row]
        cell.configure(
            name: place.name,
            rating: place.rating,
            ratingCount: place.ratingCount,
            category: place.category,
            distance: favoriteVM.formattedDistance(for: place),
            price: place.price
        )
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let favorite = data[indexPath.row]

        guard
            let tabBar = tabBarController,
            let nav = tabBar.viewControllers?.first as? UINavigationController,
            let mapVC = nav.viewControllers.first as? MapViewController
        else { return }

        tabBar.selectedIndex = 0

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            mapVC.focusOnFavoriteLocation(favorite)
        }
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Sil") { [weak self] _, _, completion in
            guard let self else {
                completion(false)
                return
            }

            let place = self.data[indexPath.row]

            Task {
                await self.favoriteVM.deleteFavoritePlace(id: place.id)
                await MainActor.run {
                    self.render(self.favoriteVM.fetchedFavoritePlacesState)
                    self.favoriteVM.resetDeleteFavoritePlaceState()
                    completion(true)
                }
            }
        }

        deleteAction.backgroundColor = .appAccent
        deleteAction.image = UIImage(systemName: "trash")

        let config = UISwipeActionsConfiguration(actions: [deleteAction])
        config.performsFirstActionWithFullSwipe = true
        return config
    }
}

// MARK: - CLLocationManagerDelegate

extension FavoritesViewController: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.last else { return }
        guard shouldRefreshDistance(for: loc) else { return }

        favoriteVM.updateUserLocation(loc)

        let visible = tableView.indexPathsForVisibleRows ?? []
        guard !visible.isEmpty else { return }

        UIView.performWithoutAnimation {
            tableView.reloadRows(at: visible, with: .none)
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Konum alınamadı: \(error.localizedDescription)")
    }
}

// MARK: - UITextFieldDelegate

extension FavoritesViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - ViewModel Rendering

private extension FavoritesViewController {

    func render(_ state: ViewState<[FavoritePlace]>) {
        switch state {
        case .idle:
            setEmptyStateVisible(false)

        case .loading:
            setEmptyStateVisible(false)

        case .success(let list):
            data = list
            emptyStateLabel.text = "Henüz bir mekan eklemediniz."
            setEmptyStateVisible(false)
            tableView.reloadData()

        case .empty:
            data = []
            emptyStateLabel.text = (searchField.text ?? "").isEmpty
                ? "Henüz bir mekan eklemediniz."
                : "Aramanızla eşleşen mekan bulunamadı."
            setEmptyStateVisible(true)
            tableView.reloadData()

        case .error(let error):
            setEmptyStateVisible(false)
            showAlert(title: "Hata", message: error.localizedDescription)
        }
    }

    func setEmptyStateVisible(_ visible: Bool) {
        emptyStateView.isHidden = !visible
        tableView.isHidden = visible
        searchContainer.isHidden = false
    }
}
