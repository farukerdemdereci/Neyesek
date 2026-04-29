//
//  SceneDelegate.swift
//  PinEatUIKit
//
//  Created by Faruk Dereci on 18.12.2025.
//

import UIKit
import Supabase

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    private lazy var manager: SupabaseManager = {
        guard
            let urlString = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_URL") as? String,
            let url = URL(string: urlString),
            let key = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_KEY") as? String,
            !key.isEmpty
        else {
            fatalError("Supabase config missing")
        }
        let client = SupabaseClient(
            supabaseURL: url,
            supabaseKey: key
        )
        return SupabaseManager(client: client)
    }()

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else { return }

        let window = UIWindow(windowScene: windowScene)
        self.window = window

        window.rootViewController = makeRoot()
        window.makeKeyAndVisible()
    }

    private func makeRoot() -> UIViewController {
        if manager.client.auth.currentUser != nil {
            return createTabBar()
        } else {
            return createLoginVC()
        }
    }
}

// MARK: - Root Switching

extension SceneDelegate {

    func resetToLogin() {
        switchRoot(to: createLoginVC())
    }

    func resetToMainApp() {
        switchRoot(to: createTabBar())
    }

    private func switchRoot(to vc: UIViewController) {
        DispatchQueue.main.async {
            guard let window = self.window else { return }

            window.rootViewController = vc

            UIView.transition(
                with: window,
                duration: 0.3,
                options: .transitionCrossDissolve,
                animations: nil
            )
        }
    }
}

// MARK: - Dependency Injection

extension SceneDelegate {

    private func createTabBar() -> UITabBarController {
        let tabBar = UITabBarController()

        let googleService = GooglePlacesService()
        let placeService = PlaceService(googleService: googleService)

        let mapVM = MapViewModel(
            placeService: placeService,
            favoritePlaceService: manager
        )

        let favoriteVM = FavoritesViewModel(
            favoritePlaceService: manager
        )

        let authVM = AuthViewModel(
            authService: manager
        )

        let filterVM = FilterViewModel()
        
        let mapVC = MapViewController(mapVM: mapVM, authVM: authVM)
        mapVC.tabBarItem = UITabBarItem(
            title: "Neyesek",
            image: UIImage(systemName: "map.fill"),
            tag: 0
        )
        
        let filterVC = FilterViewController(mapVM: mapVM, filterVM: filterVM
        )
        filterVC.tabBarItem = UITabBarItem(
            title: "Filtrele",
            image: UIImage(systemName: "slider.horizontal.3"),
            tag: 1
        )

        let favoriteVC = FavoritesViewController(favoriteVM: favoriteVM)
        favoriteVC.tabBarItem = UITabBarItem(
            title: "Favoriler",
            image: UIImage(systemName: "bookmark.fill"),
            tag: 2
        )

        tabBar.viewControllers = [
            UINavigationController(rootViewController: mapVC),
            UINavigationController(rootViewController: filterVC),
            UINavigationController(rootViewController: favoriteVC)
        ]

        setupTabBarAppearance(tabBar)

        return tabBar
    }

    private func createLoginVC() -> UIViewController {
        let authVM = AuthViewModel(authService: manager)
        return LoginViewController(vm: authVM)
    }

    private func setupTabBarAppearance(_ tabBar: UITabBarController) {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white

        appearance.stackedLayoutAppearance.normal.iconColor = .secondaryLabel
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.secondaryLabel
        ]

        appearance.stackedLayoutAppearance.selected.iconColor = .appAccent
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor.appAccent
        ]

        tabBar.tabBar.standardAppearance = appearance
        tabBar.tabBar.scrollEdgeAppearance = appearance
    }
}
