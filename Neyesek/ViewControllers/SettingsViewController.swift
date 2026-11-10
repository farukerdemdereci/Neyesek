//
//  SettingsViewController.swift
//  Neyesek
//
//  Created by Faruk on 25.05.2026.
//

import UIKit

final class SettingsViewController: UIViewController {

    // MARK: - Dependencies

    private let vm: AuthViewModel

    // MARK: - UI Components

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Ayarlar"
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.textColor = .appTextColor
        label.textAlignment = .center
        return label
    }()

    private let accountTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Hesabınız"
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .appTextColor
        return label
    }()

    private let userEmailLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        return label
    }()

    private lazy var accountCard: UIView = {
        let view = UIView()
        view.backgroundColor = .appSecondary
        view.layer.cornerRadius = 28

        let icon = UIImageView(image: UIImage(systemName: "person.crop.circle"))
        icon.tintColor = .appTextColor
        icon.translatesAutoresizingMaskIntoConstraints = false

        let textStack = UIStackView(arrangedSubviews: [
            accountTitleLabel,
            userEmailLabel
        ])
        textStack.axis = .vertical
        textStack.spacing = 6
        textStack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(icon)
        view.addSubview(textStack)

        NSLayoutConstraint.activate([
            icon.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            icon.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            icon.widthAnchor.constraint(equalToConstant: 32),
            icon.heightAnchor.constraint(equalToConstant: 32),

            textStack.topAnchor.constraint(equalTo: view.topAnchor, constant: 16),
            textStack.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -16),
            textStack.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: 12),
            textStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])

        return view
    }()

    private let logoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false

        button.setTitle("  Çıkış Yap", for: .normal)
        button.setTitleColor(.appTextColor, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)

        button.setImage(UIImage(systemName: "rectangle.portrait.and.arrow.right"), for: .normal)
        button.tintColor = .appTextColor

        button.backgroundColor = .appSecondary
        button.layer.cornerRadius = 28

        return button
    }()

    private let deleteAccountButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false

        button.setTitle("  Hesabı Sil", for: .normal)
        button.setTitleColor(.systemRed, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)

        button.setImage(UIImage(systemName: "trash"), for: .normal)
        button.tintColor = .systemRed

        button.backgroundColor = .appSecondary
        button.layer.cornerRadius = 28

        return button
    }()

    private let supportButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false

        button.setTitle("  Destek", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)

        button.setImage(UIImage(systemName: "headphones"), for: .normal)
        button.tintColor = .systemBlue

        button.backgroundColor = .appSecondary
        button.layer.cornerRadius = 28

        return button
    }()

    private lazy var mainStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            titleLabel,
            accountCard,
            logoutButton,
            deleteAccountButton,
            supportButton
        ])

        stack.axis = .vertical
        stack.alignment = .fill
        stack.spacing = 18
        stack.translatesAutoresizingMaskIntoConstraints = false

        stack.setCustomSpacing(14, after: titleLabel)
        stack.setCustomSpacing(20, after: accountCard)
        stack.setCustomSpacing(10, after: logoutButton)
        stack.setCustomSpacing(10, after: deleteAccountButton)

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

        view.backgroundColor = .appBackground
        userEmailLabel.text = vm.currentUserEmail

        setupUI()
        setupActions()
    }
}

// MARK: - Setup

private extension SettingsViewController {

    func setupUI() {
        view.addSubview(mainStack)

        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            mainStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 28),
            mainStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -28),

            logoutButton.heightAnchor.constraint(equalToConstant: 56),
            deleteAccountButton.heightAnchor.constraint(equalToConstant: 56),
            supportButton.heightAnchor.constraint(equalToConstant: 56)
        ])
    }

    func setupActions() {
        supportButton.addTarget(self, action: #selector(supportTapped), for: .touchUpInside)
        logoutButton.addTarget(self, action: #selector(logoutTapped), for: .touchUpInside)
        deleteAccountButton.addTarget(self, action: #selector(deleteAccountTapped), for: .touchUpInside)
    }
}

// MARK: - Actions

private extension SettingsViewController {

    @objc
    func supportTapped() {
        showAlert(
            title: "Destek",
            message: "Sorularınız ve geri bildirimleriniz için bizimle iletişime geçebilirsiniz.\n\nfarukerdemdereci@gmail.com"
        )
    }

    @objc
    func logoutTapped() {
        let alert = UIAlertController(
            title: "Çıkış Yap",
            message: "Hesabınızdan çıkış yapmak istediğinize emin misiniz?",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Vazgeç", style: .cancel))

        alert.addAction(UIAlertAction(title: "Çıkış Yap", style: .destructive) { [weak self] _ in
            guard let self else { return }

            Task {
                await self.vm.signOut()

                await MainActor.run {
                    self.dismiss(animated: true)

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
    func deleteAccountTapped() {
        let alert = UIAlertController(
            title: "Hesabı Sil",
            message: "Bu işlem geri alınamaz. Hesabınız ve kayıtlı favorileriniz silinecektir.",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Vazgeç", style: .cancel))

        alert.addAction(UIAlertAction(title: "Hesabı Sil", style: .destructive) { [weak self] _ in
            guard let self else { return }

            Task {
                do {

                    await self.vm.deleteAccount()

                    await MainActor.run {

                        let successAlert = UIAlertController(
                            title: "Hesap Silindi",
                            message: "Hesabınız başarıyla silindi.",
                            preferredStyle: .alert
                        )

                        successAlert.addAction(
                            UIAlertAction(title: "Tamam", style: .default) { _ in

                                self.dismiss(animated: true)

                                if let scene = self.view.window?.windowScene,
                                   let sceneDelegate = scene.delegate as? SceneDelegate {
                                    sceneDelegate.resetToLogin()
                                }
                            }
                        )

                        self.present(successAlert, animated: true)
                    }

                }
            }
        })

        present(alert, animated: true)
    }
}
