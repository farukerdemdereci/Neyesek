//
//  FavoriteViewModel.swift
//  PinEatUIKit
//
//  Created by Faruk Dereci on 26.12.2025.
//

import Foundation
import CoreLocation

@MainActor
final class FavoritesViewModel: ObservableObject {

    // MARK: - State

    @Published private(set) var fetchedFavoritePlacesState: ViewState<[FavoritePlace]> = .idle
    @Published private(set) var deleteFavoritePlaceState: ViewState<Void> = .idle

    // MARK: - Stored Properties

    private var favoritePlaces: [FavoritePlace] = []
    private var filteredFavoritePlaces: [FavoritePlace] = []
    private var currentUserLocation: CLLocation?

    private let favoritePlaceService: FavoritePlaceServiceProtocol

    // MARK: - Init

    init(favoritePlaceService: FavoritePlaceServiceProtocol) {
        self.favoritePlaceService = favoritePlaceService
    }

    // MARK: - Fetch Actions

    func fetchFavoritePlaces() async {
        fetchedFavoritePlacesState = .loading

        do {
            let fetched = try await favoritePlaceService.fetchFavoritePlaces()
            let ordered = Array(fetched.reversed())

            favoritePlaces = ordered
            filteredFavoritePlaces = ordered

            fetchedFavoritePlacesState = ordered.isEmpty ? .empty : .success(ordered)

        } catch {
            fetchedFavoritePlacesState = .error(error)
        }
    }

    // MARK: - Favorite Actions

    func deleteFavoritePlace(id: UUID) async {
        deleteFavoritePlaceState = .loading

        do {
            try await favoritePlaceService.deleteFavoritePlace(id: id)

            favoritePlaces.removeAll { $0.id == id }
            filteredFavoritePlaces.removeAll { $0.id == id }

            deleteFavoritePlaceState = .success(())
            fetchedFavoritePlacesState = filteredFavoritePlaces.isEmpty
                ? .empty
                : .success(filteredFavoritePlaces)

        } catch {
            deleteFavoritePlaceState = .error(error)
        }
    }

    func resetDeleteFavoritePlaceState() {
        deleteFavoritePlaceState = .idle
    }

    // MARK: - Search

    func filterContentForSearchText(_ searchText: String) {
        if searchText.isEmpty {
            filteredFavoritePlaces = favoritePlaces
        } else {
            filteredFavoritePlaces = favoritePlaces.filter {
                $0.name.localizedCaseInsensitiveContains(searchText)
            }
        }

        fetchedFavoritePlacesState = filteredFavoritePlaces.isEmpty ? .empty : .success(filteredFavoritePlaces)
    }

    // MARK: - User Location

    func updateUserLocation(_ location: CLLocation) {
        currentUserLocation = location
        
        if !filteredFavoritePlaces.isEmpty {
            fetchedFavoritePlacesState = .success(filteredFavoritePlaces)
        }
    }

    // MARK: - Helpers

    func distance(for place: FavoritePlace) -> CLLocationDistance? {
        guard let userLocation = currentUserLocation else { return nil }

        let placeLocation = CLLocation(
            latitude: place.latitude,
            longitude: place.longitude
        )

        return userLocation.distance(from: placeLocation)
    }
    
    func formattedDistance(for place: FavoritePlace) -> String {
        DistanceFormatter.format(distance: distance(for: place))
    }
    
    func priceText(for place: FavoritePlace) -> String {
        guard let price = place.price else { return "—" }
        return String(repeating: "₺", count: price)
    }
    
    func ratingText(for place: FavoritePlace) -> String {
        guard let rating = place.rating else { return "—" }

        if let count = place.ratingCount {
            return "\(String(format: "%.1f", rating)) (\(count))"
        }

        return String(format: "%.1f", rating)
    }
}
