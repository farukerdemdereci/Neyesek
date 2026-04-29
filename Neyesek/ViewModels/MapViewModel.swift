//
//  LocationViewModel.swift
//  PinEatUIKit
//
//  Created by Faruk Dereci on 18.12.2025.
//

import Foundation
import CoreLocation
import UIKit

@MainActor
final class MapViewModel: ObservableObject {
    
    @Published private(set) var fetchedPlacesState: ViewState<[Place]> = .idle
    @Published private(set) var fetchedFavoritePlacesState: ViewState<[FavoritePlace]> = .idle
    @Published private(set) var saveFavoritePlaceState: ViewState<Void> = .idle
    @Published private(set) var deleteFavoritePlaceState: ViewState<Void> = .idle
    
    var isAPIKeyMissing: Bool {
        placeService.isAPIKeyMissing
    }
    
    @Published private(set) var places: [Place] = []
    @Published private(set) var favoritePlaces: [FavoritePlace] = []
    
    @Published private(set) var favoriteStatusText: String?
    @Published private(set) var favoriteStatusColor: UIColor = .systemGray
    
    private var suggestionIndex: Int = 0
    private var lastSuggestionFilter: PlaceFilter?
    
    private(set) var currentUserLocation: CLLocation?
    var currentFilter: PlaceFilter = .default
    
    private let placeService: PlaceServiceProtocol
    private let favoritePlaceService: FavoritePlaceServiceProtocol
    
    var isRequestLimitReached: Bool {
        RequestLimiter.shared.isLimitReached
    }
    
    var remainingRequestCount: Int {
        RequestLimiter.shared.remainingRequests
    }
    
    init(
        placeService: PlaceServiceProtocol,
        favoritePlaceService: FavoritePlaceServiceProtocol
    ) {
        self.placeService = placeService
        self.favoritePlaceService = favoritePlaceService
    }
    
    func fetchPlaces(userLocation: UserLocation, filter: PlaceFilter? = nil) async {
        fetchedPlacesState = .loading
        
        let appliedFilter = filter ?? currentFilter
        currentFilter = appliedFilter
        
        if let cachedPlaces = PlacesCache.shared.get(
            userLocation: userLocation,
            filter: appliedFilter
        ) {
            places = cachedPlaces
            fetchedPlacesState = cachedPlaces.isEmpty ? .empty : .success(cachedPlaces)
            return
        }
        
        do {
            let fetchedPlaces = try await placeService.fetchPlaces(
                userLocation: userLocation,
                filter: appliedFilter
            )
            
            places = fetchedPlaces
            
            PlacesCache.shared.save(
                places: fetchedPlaces,
                userLocation: userLocation,
                filter: appliedFilter
            )
            
            fetchedPlacesState = fetchedPlaces.isEmpty ? .empty : .success(fetchedPlaces)
        } catch {
            places = []
            fetchedPlacesState = .error(error)
        }
    }
    
    func fetchFavoritePlaces() async {
        fetchedFavoritePlacesState = .loading
        
        do {
            let fetchedFavoritePlaces = try await favoritePlaceService.fetchFavoritePlaces()
            favoritePlaces = fetchedFavoritePlaces
            fetchedFavoritePlacesState = fetchedFavoritePlaces.isEmpty ? .empty : .success(fetchedFavoritePlaces)
        } catch {
            favoritePlaces = []
            fetchedFavoritePlacesState = .error(error)
        }
    }
    
    func saveFavoritePlace(
        name: String,
        latitude: Double,
        longitude: Double,
        placeId: String,
        category: String,
        price: Int?,
        rating: Double?,
        ratingCount: Int?
    ) async {
        saveFavoritePlaceState = .loading
        
        do {
            try await favoritePlaceService.saveFavoritePlace(
                name: name,
                category: category,
                latitude: latitude,
                longitude: longitude,
                placeId: placeId,
                price: price,
                rating: rating,
                ratingCount: ratingCount
            )
            
            saveFavoritePlaceState = .success(())
        } catch {
            saveFavoritePlaceState = .error(error)
        }
    }
    
    func fetchFavoriteOpenStatus(for favorite: FavoritePlace) async {
        favoriteStatusText = "Kontrol ediliyor..."
        favoriteStatusColor = .systemGray
        
        if let livePlace = places.first(where: { $0.id == favorite.placeId }) {
            let status = openStatus(for: livePlace)
            favoriteStatusText = status.text
            favoriteStatusColor = status.color
            return
        }
        
        do {
            let isOpen = try await placeService.fetchFavoritePlaceOpenStatus(
                placeId: favorite.placeId
            )
            
            if let isOpen {
                favoriteStatusText = isOpen ? "Açık" : "Kapalı"
                favoriteStatusColor = isOpen ? .systemGreen : .systemRed
            } else {
                favoriteStatusText = "Bilinmiyor"
                favoriteStatusColor = .systemGray
            }
        } catch {
            if RequestLimiter.shared.isLimitReached {
                favoriteStatusText = "Limit doldu"
            } else {
                favoriteStatusText = "Bilinmiyor"
            }
            
            favoriteStatusColor = .systemGray
        }
    }
    
    func deleteFavoritePlace(id: UUID) async {
        deleteFavoritePlaceState = .loading
        
        do {
            try await favoritePlaceService.deleteFavoritePlace(id: id)
            deleteFavoritePlaceState = .success(())
        } catch {
            deleteFavoritePlaceState = .error(error)
        }
    }
    
    func fetchPlacesWithCurrentLocation(filter: PlaceFilter) async {
        guard let currentUserLocation else { return }
        
        let userLocation = UserLocation(
            latitude: currentUserLocation.coordinate.latitude,
            longitude: currentUserLocation.coordinate.longitude
        )
        
        await fetchPlaces(userLocation: userLocation, filter: filter)
    }
    
    func isFavorite(placeId: String) -> Bool {
        favoritePlaces.contains { $0.placeId == placeId }
    }
    
    func resetFavoriteSaveState() {
        saveFavoritePlaceState = .idle
    }
    
    func resetDeleteFavoritePlaceState() {
        deleteFavoritePlaceState = .idle
    }
    
    func updateUserLocation(_ location: CLLocation) {
        currentUserLocation = location
    }
    
    func distance(for place: Place) -> CLLocationDistance? {
        guard let userLocation = currentUserLocation else { return nil }
        
        let placeLocation = CLLocation(
            latitude: place.latitude,
            longitude: place.longitude
        )
        
        return userLocation.distance(from: placeLocation)
    }
    
    func formattedDistance(for place: Place) -> String {
        DistanceFormatter.format(distance: distance(for: place))
    }
    
    func priceText(for place: Place) -> String {
        guard let price = place.price else { return "Fiyat yok" }
        return String(repeating: "₺", count: price)
    }
    
    func ratingText(for place: Place) -> String {
        guard let rating = place.rating else { return "Puan yok" }
        return String(format: "%.1f", rating)
    }
    
    func ratingCountText(for place: Place) -> String {
        guard let count = place.ratingCount else {
            return "Değerlendirme yok"
        }
        
        return " • (\(count))"
    }
    
    func openStatus(for place: Place) -> (text: String, color: UIColor) {
        guard let isOpen = place.isOpen else {
            return ("Bilinmiyor", .systemGray)
        }
        
        return isOpen
            ? ("Açık", .systemGreen)
            : ("Kapalı", .systemRed)
    }
    
    func suggestPlace(filter: PlaceFilter) async -> Place? {
        guard let currentUserLocation else { return nil }
        
        let userLocation = UserLocation(
            latitude: currentUserLocation.coordinate.latitude,
            longitude: currentUserLocation.coordinate.longitude
        )
        
        if places.isEmpty || lastSuggestionFilter != filter {
            await fetchPlaces(userLocation: userLocation, filter: filter)
            lastSuggestionFilter = filter
            suggestionIndex = 0
        }
        
        guard !places.isEmpty else { return nil }
        
        let filtered = places.filter { place in
            if let minRating = filter.minRating, (place.rating ?? 0) < minRating {
                return false
            }
            
            if let price = filter.price {
                guard let placePrice = place.price else { return false }
                if placePrice > price { return false }
            }
            
            return true
        }
        
        let openPlaces = filtered.filter { $0.isOpen == true }
        guard !openPlaces.isEmpty else { return nil }
        
        func score(for place: Place) -> Double {
            let rating = place.rating ?? 0
            let count = place.ratingCount ?? 0
            return rating * log(Double(count + 1))
        }
        
        let sorted = openPlaces.sorted {
            score(for: $0) > score(for: $1)
        }
        
        let candidates = Array(sorted.prefix(10))
        guard !candidates.isEmpty else { return nil }
        
        let place = candidates[suggestionIndex % candidates.count]
        suggestionIndex += 1
        
        return place
    }
}
