//
//  LoginViewController.swift
//  PinEatUIKit
//
//  Created by Faruk Dereci on 18.12.2025.
//

import UIKit

final class LoginViewController: UIViewController {

    // MARK: - Dependencies

    private let vm: AuthViewModel

    // MARK: - UI Components

    private let cardView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .appSecondary
        view.layer.cornerRadius = 32

        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.30
        view.layer.shadowOffset = CGSize(width: 0, height: 15)
        view.layer.shadowRadius = 15

        return view
    }()

    private let logoImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "neyesek_logo"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.layer.shadowRadius = 10
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Giriş Yap"
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = .appTextColor
        label.textAlignment = .center
        return label
    }()

    private let appleButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.image = UIImage(systemName: "applelogo")?
            .withConfiguration(UIImage.SymbolConfiguration(pointSize: 19, weight: .medium))
        config.imagePlacement = .leading
        config.imagePadding = 10
        config.baseBackgroundColor = .appTextColor
        config.baseForegroundColor = .white
        config.background.cornerRadius = 28

        var title = AttributedString("Apple ile Devam Et")
        title.font = .systemFont(ofSize: 16, weight: .semibold)
        config.attributedTitle = title

        let button = UIButton(configuration: config)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let googleButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.image = UIImage(named: "google_icon")?
            .resized(to: CGSize(width: 23, height: 23))
            .withRenderingMode(.alwaysOriginal)
        config.imagePlacement = .leading
        config.imagePadding = 10
        config.baseBackgroundColor = .white
        config.baseForegroundColor = .appTextColor
        config.background.strokeColor = UIColor.appTextColor
        config.background.strokeWidth = 1.2
        config.background.cornerRadius = 28

        var title = AttributedString("Google ile Devam Et")
        title.font = .systemFont(ofSize: 16, weight: .semibold)
        config.attributedTitle = title

        let button = UIButton(configuration: config)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let infoLabel: UILabel = {
        let label = UILabel()
        label.text = "Favorilerinizi kaydetmek için giriş yapmalısınız."
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private lazy var mainStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            titleLabel,
            appleButton,
            googleButton,
            infoLabel
        ])

        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 18
        stack.translatesAutoresizingMaskIntoConstraints = false

        stack.setCustomSpacing(40, after: titleLabel)
        stack.setCustomSpacing(20, after: appleButton)
        stack.setCustomSpacing(30, after: googleButton)

        return stack
    }()

    // MARK: - Init

    init(vm: AuthViewModel) {
        self.vm = vm
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        setupUI()
        setupActions()
        render(vm.state)
    }
}

// MARK: - Setup UI

private extension LoginViewController {

    func setupUI() {
        setupHierarchy()
        setupConstraints()
    }

    func setupHierarchy() {
        view.addSubview(cardView)
        view.addSubview(logoImageView)
        cardView.addSubview(mainStack)
    }

    func setupConstraints() {
        NSLayoutConstraint.activate([
            cardView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 20),
            cardView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 28),
            cardView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -28),

            mainStack.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 40),
            mainStack.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -36),
            mainStack.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 24),
            mainStack.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -24),

            logoImageView.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),
            logoImageView.bottomAnchor.constraint(equalTo: cardView.topAnchor, constant: 10),

            logoImageView.widthAnchor.constraint(equalToConstant: 172),
            logoImageView.heightAnchor.constraint(equalToConstant: 172),

            appleButton.heightAnchor.constraint(equalToConstant: 60),
            appleButton.widthAnchor.constraint(equalTo: mainStack.widthAnchor),

            googleButton.heightAnchor.constraint(equalToConstant: 60),
            googleButton.widthAnchor.constraint(equalTo: mainStack.widthAnchor)
        ])
    }

    func setupActions() {
        googleButton.addTarget(self, action: #selector(googleTapped), for: .touchUpInside)
        appleButton.addTarget(self, action: #selector(appleTapped), for: .touchUpInside)
    }
}

// MARK: - Actions

private extension LoginViewController {

    @objc
    func googleTapped() {
        googleButton.isEnabled = false
        showLoading()

        Task {
            await vm.signInWithGoogle()

            await MainActor.run {
                self.googleButton.isEnabled = true
                self.hideLoading()
                self.render(self.vm.state)
            }
        }
    }

    @objc
    func appleTapped() {
        showAlert(title: "Yakında", message: "Apple ile giriş yakında eklenecek.")
    }
}

// MARK: - ViewModel Rendering

private extension LoginViewController {

    func render(_ state: ViewState<Void>) {
        switch state {
        case .idle:
            hideLoading()

        case .loading:
            showLoading()

        case .success:
            hideLoading()

            if let scene = view.window?.windowScene,
               let sceneDelegate = scene.delegate as? SceneDelegate {
                sceneDelegate.resetToMainApp()
            }

        case .empty:
            hideLoading()

        case .error(let error):
            hideLoading()
            showAlert(title: "Hata", message: error.localizedDescription)
        }
    }
}

// MARK: - Image Resize Helper

private extension UIImage {
    func resized(to size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
