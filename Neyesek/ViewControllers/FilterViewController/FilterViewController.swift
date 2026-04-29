//
//  File.swift
//  Pineat
//
//  Created by Faruk on 25.03.2026.
//

import UIKit
import CoreLocation

final class FilterViewController: UIViewController {
    
    // MARK: - Dependencies
    
    private let mapVM: MapViewModel
    private let filterVM: FilterViewModel
    
    // MARK: - State
    
    private var radiusButtons: [UIButton] = []
    private var ratingButtons: [UIButton] = []
    private var priceButtons: [UIButton] = []
    
    // MARK: - UI Elements
    
    private let backgroundView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .appAccent
        return view
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Kategori seç → filtreleri uygula → sonuçları gör"
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.textColor = .secondaryLabel
        return label
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
    
    private let containerShadowWrapper: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.40
        view.layer.shadowRadius = 9
        view.layer.shadowOffset = CGSize(width: 0, height: -3)
        return view
    }()
    
    private let scrollView: UIScrollView = {
        let view = UIScrollView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.showsVerticalScrollIndicator = false
        return view
    } ()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let radiusTitleLabel = FilterViewController.makeSectionTitle("Uzaklık", size: 22, color: .appTextColor)
    private let ratingTitleLabel = FilterViewController.makeSectionTitle("Puan", size: 22, color: .appTextColor)
    private let priceTitleLabel = FilterViewController.makeSectionTitle("Fiyat", size: 22, color: .appTextColor)
    private let categoryTitleLabel = FilterViewController.makeSectionTitle("Kategoriler", size: 22, color: .appTextColor)
    
    private let priceInfoLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Bazı mekanlarda fiyat bilgisi bulunmayabilir."
        label.font = .systemFont(ofSize: 12, weight: .semibold)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var categoryCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 16
        
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.showsHorizontalScrollIndicator = false
        view.delegate = self
        view.dataSource = self
        view.register(
            CategoryFilterCustomCell.self,
            forCellWithReuseIdentifier: CategoryFilterCustomCell.identifier
        )
        return view
    }()
    
    private let radiusStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.spacing = 12
        stack.distribution = .fill
        return stack
    }()
    
    private let ratingStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.spacing = 8
        stack.distribution = .fill
        return stack
    }()
    
    private let priceStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.spacing = 8
        stack.distribution = .fill
        return stack
    }()
    
    private let applyButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Mekanları Göster", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        button.backgroundColor = .appAccent
        button.layer.cornerRadius = 28
        return button
    }()
    
    private let suggestionButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Mekan Öner", for: .normal)
        button.setTitleColor(.appTextColor, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        button.backgroundColor = .white
        button.layer.borderWidth = 1.2
        button.layer.borderColor = UIColor.appTextColor.cgColor
        button.layer.cornerRadius = 28
        return button
    }()
    
    // MARK: - Init
    
    init(mapVM: MapViewModel, filterVM: FilterViewModel) {
        self.mapVM = mapVM
        self.filterVM = filterVM
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupButtons()
        setupActions()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNav()
    }
}

// MARK: - Setup UI

private extension FilterViewController {
    
    func setupUI() {
        setupHierarchy()
        setupConstraints()
    }
    
    func setupHierarchy() {
        view.addSubview(backgroundView)
        view.addSubview(containerShadowWrapper)
        
        containerShadowWrapper.addSubview(contentContainerView)
        contentContainerView.addSubview(scrollView)
        contentContainerView.addSubview(suggestionButton)
        contentContainerView.addSubview(applyButton)
        scrollView.addSubview(contentView)

        [
            subtitleLabel,
            categoryTitleLabel,
            categoryCollectionView,
            radiusTitleLabel,
            radiusStack,
            ratingTitleLabel,
            ratingStack,
            priceTitleLabel,
            priceStack,
            priceInfoLabel
        ].forEach {
            contentView.addSubview($0)
        }
    }
    
    func setupConstraints() {
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
            
            scrollView.topAnchor.constraint(equalTo: contentContainerView.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: contentContainerView.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: contentContainerView.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: applyButton.topAnchor, constant: -16),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            subtitleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 28),
            subtitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            subtitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            
            categoryTitleLabel.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 12),
            categoryTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            
            categoryCollectionView.topAnchor.constraint(equalTo: categoryTitleLabel.bottomAnchor, constant: 16),
            categoryCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            categoryCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            categoryCollectionView.heightAnchor.constraint(equalToConstant: 160),
            
            radiusTitleLabel.topAnchor.constraint(equalTo: categoryCollectionView.bottomAnchor, constant: 28),
            radiusTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            
            radiusStack.topAnchor.constraint(equalTo: radiusTitleLabel.bottomAnchor, constant: 16),
            radiusStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            radiusStack.heightAnchor.constraint(equalToConstant: 44),
            
            ratingTitleLabel.topAnchor.constraint(equalTo: radiusStack.bottomAnchor, constant: 28),
            ratingTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            
            ratingStack.topAnchor.constraint(equalTo: ratingTitleLabel.bottomAnchor, constant: 16),
            ratingStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            ratingStack.heightAnchor.constraint(equalToConstant: 44),
            
            priceTitleLabel.topAnchor.constraint(equalTo: ratingStack.bottomAnchor, constant: 28),
            priceTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            
            priceStack.topAnchor.constraint(equalTo: priceTitleLabel.bottomAnchor, constant: 16),
            priceStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            priceStack.heightAnchor.constraint(equalToConstant: 44),
            
            priceInfoLabel.topAnchor.constraint(equalTo: priceStack.bottomAnchor, constant: 12),
            priceInfoLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            priceInfoLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            priceInfoLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            applyButton.leadingAnchor.constraint(equalTo: contentContainerView.leadingAnchor, constant: 24),
            applyButton.bottomAnchor.constraint(equalTo: contentContainerView.safeAreaLayoutGuide.bottomAnchor, constant: -12),
            applyButton.heightAnchor.constraint(equalToConstant: 56),
            
            suggestionButton.leadingAnchor.constraint(equalTo: applyButton.trailingAnchor, constant: 12),
            suggestionButton.trailingAnchor.constraint(equalTo: contentContainerView.trailingAnchor, constant: -24),
            suggestionButton.bottomAnchor.constraint(equalTo: applyButton.bottomAnchor),
            suggestionButton.heightAnchor.constraint(equalToConstant: 56),
            
            applyButton.widthAnchor.constraint(equalTo: suggestionButton.widthAnchor, multiplier: 1.5)
        ])
    }
    
    func setupNav() {
        navigationItem.title = "Ne yemek istersiniz?"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 34, weight: .bold)
        ]
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.tintColor = .white
    }
    
    func setupButtons() {
        radiusButtons = ["~300m", "~600m", "~1km", "~2km"].enumerated().map {
            makeButton(title: $1, tag: $0, action: #selector(radiusTapped))
        }
        
        ratingButtons = ["Hepsi", "3+", "3.5+", "4.0+", "4.5+"].enumerated().map {
            makeButton(title: $1, tag: $0, action: #selector(ratingTapped))
        }
        
        priceButtons = ["Hepsi", "₺", "₺₺", "₺₺₺", "₺₺₺₺"].enumerated().map {
            makeButton(title: $1, tag: $0, action: #selector(priceTapped))
        }
        
        radiusButtons.forEach { radiusStack.addArrangedSubview($0) }
        ratingButtons.forEach { ratingStack.addArrangedSubview($0) }
        priceButtons.forEach { priceStack.addArrangedSubview($0) }
        
        updateRadiusButtons()
        updateRatingButtons()
        updatePriceButtons()
    }

    func setupActions() {
        applyButton.addTarget(self, action: #selector(applyTapped), for: .touchUpInside)
        suggestionButton.addTarget(self, action: #selector(suggestTapped), for: .touchUpInside)
    }
}

// MARK: - Actions

private extension FilterViewController {
    
    @objc func radiusTapped(_ sender: UIButton) {
        filterVM.selectRadius(at: sender.tag)
        updateRadiusButtons()
    }
    
    @objc func ratingTapped(_ sender: UIButton) {
        filterVM.selectRating(at: sender.tag)
        updateRatingButtons()
    }
    
    @objc func priceTapped(_ sender: UIButton) {
        filterVM.selectPrice(at: sender.tag)
        updatePriceButtons()
    }

    @objc func applyTapped() {
        guard !mapVM.isAPIKeyMissing else {
            showAlert(
                title: "API Key Eksik",
                message: "Mekanları görmek için Secrets.xcconfig dosyasına GOOGLE_API_KEY eklemelisin."
            )
            return
        }
        
        let filter = filterVM.makeFilter()

        if mapVM.isRequestLimitReached {
            showAlert(
                title: "Günlük Hak Doldu",
                message: "Bugünlük arama hakkınız doldu. Yarın tekrar deneyebilirsiniz."
            )
            return
        }
        
        applyButton.isEnabled = false
        applyButton.alpha = 0.6
        showLoading()

        Task {
            await mapVM.fetchPlacesWithCurrentLocation(filter: filter)

            await MainActor.run {
                hideLoading()
                self.applyButton.isEnabled = true
                self.applyButton.alpha = 1

                if self.mapVM.isRequestLimitReached, self.mapVM.places.isEmpty {
                    self.showAlert(
                        title: "Günlük Hak Doldu",
                        message: "Bugünlük arama hakkınız doldu. Yarın tekrar deneyebilirsiniz."
                    )
                    return
                }

                self.tabBarController?.selectedIndex = 0
            }
        }
    }
    
    @objc func suggestTapped() {
        guard !mapVM.isAPIKeyMissing else {
            showAlert(
                title: "API Key Eksik",
                message: "Mekan önermek için Secrets.xcconfig dosyasına GOOGLE_API_KEY eklemelisin."
            )
            return
        }
        
        let filter = filterVM.makeFilter()

        if mapVM.isRequestLimitReached {
            showAlert(
                title: "Günlük Hak Doldu",
                message: "Bugünlük öneri hakkınız doldu. Yarın tekrar deneyebilirsiniz."
            )
            return
        }

        Task {
            showLoading()
            let suggestedPlace = await mapVM.suggestPlace(filter: filter)

            await MainActor.run {
                hideLoading()
                if mapVM.isRequestLimitReached, suggestedPlace == nil {
                    showAlert(
                        title: "Günlük Hak Doldu",
                        message: "Bugünlük öneri hakkınız doldu. Yarın tekrar deneyebilirsiniz."
                    )
                    return
                }

                guard let suggestedPlace else {
                    showAlert(
                        title: "Mekan Bulunamadı",
                        message: "Aradığınız filtrelere uygun mekan bulunmamaktadır."
                    )
                    return
                }
                self.presentSuggestionDetail(place: suggestedPlace, filter: filter)
            }
        }
    }
}

// MARK: - Navigation / Presentation Helpers

private extension FilterViewController {
    
    func presentSuggestionDetail(place: Place, filter: PlaceFilter) {
        let suggestedVM = SuggestedPlaceViewModel(
            place: place,
            currentUserLocation: mapVM.currentUserLocation
        )
        
        let suggestedVC = SuggestedPlaceViewController(vm: suggestedVM)

        suggestedVC.onSuggestAnother = { [weak self] in
            guard let self else { return }

            Task {
                let nextPlace = await self.mapVM.suggestPlace(filter: filter)

                await MainActor.run {
                    guard let nextPlace else {
                        self.showAlert(
                            title: "Mekan Bulunamadı",
                            message: "Başka mekan bulunamadı."
                        )
                        return
                    }
                    self.presentSuggestionDetail(place: nextPlace, filter: filter)
                }
            }
        }

        suggestedVC.modalPresentationStyle = .pageSheet

        if let sheet = suggestedVC.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 32
        }

        present(suggestedVC, animated: true)
    }
}

// MARK: - UI Helpers

private extension FilterViewController {
    
    static func makeSectionTitle(_ text: String, size: CGFloat, color: UIColor) -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = text
        label.font = .systemFont(ofSize: size, weight: .bold)
        label.textColor = color
        return label
    }
    
    func makeButton(title: String, tag: Int, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 13, weight: .bold)
        button.layer.cornerRadius = 22
        
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: 64),
            button.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        button.tag = tag
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }
    
    func styleSelection(_ button: UIButton, isSelected: Bool) {
        UIView.animate(withDuration: 0.25) {
            button.backgroundColor = isSelected ? .appAccent : .appSecondary
            button.setTitleColor(isSelected ? .white : .appTextColor, for: .normal)
            button.transform = isSelected ? CGAffineTransform(scaleX: 1.05, y: 1.05) : .identity
        }
    }
    
    func updateRadiusButtons() {
        radiusButtons.enumerated().forEach {
            styleSelection($1, isSelected: filterVM.isRadiusSelected(at: $0))
        }
    }
    
    func updateRatingButtons() {
        ratingButtons.enumerated().forEach {
            styleSelection($1, isSelected: filterVM.isRatingSelected(at: $0))
        }
    }
    
    func updatePriceButtons() {
        priceButtons.enumerated().forEach {
            styleSelection($1, isSelected: filterVM.isPriceSelected(at: $0))
        }
    }
}

// MARK: - UICollectionViewDelegate & DataSource

extension FilterViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        filterVM.categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: CategoryFilterCustomCell.identifier,
            for: indexPath
        ) as! CategoryFilterCustomCell
        
        let item = filterVM.categories[indexPath.item]
        cell.configure(
            title: item.title,
            image: UIImage(named: item.imageName),
            isSelected: filterVM.isCategorySelected(at: indexPath.item)
        )
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        filterVM.selectCategory(at: indexPath.item)
        collectionView.reloadData()
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        CGSize(width: 130, height: 150)
    }
}
