//
//  FilterViewModel.swift
//  Pineat
//
//  Created by Faruk on 21.04.2026.
//

import Foundation

@MainActor
final class FilterViewModel: ObservableObject {
    
    struct FilterCategory: Equatable {
        let title: String
        let imageName: String
        let query: String
    }
    
    @Published private(set) var selectedCategory: FilterCategory
    @Published private(set) var selectedRadiusIndex: Int = 1
    @Published private(set) var selectedRatingIndex: Int = 0
    @Published private(set) var selectedPriceIndex: Int = 0
    
    let categories: [FilterCategory] = [
        .init(title: "Rastgele", imageName: "category_random", query: "restaurant"),
        .init(title: "Burger", imageName: "category_burger", query: "burger"),
        .init(title: "Pizza", imageName: "category_pizza", query: "pizza"),
        .init(title: "Döner", imageName: "category_doner", query: "kebab"),
        .init(title: "Kebap", imageName: "category_kebab", query: "kebab"),
        .init(title: "Makarna", imageName: "category_pasta", query: "pasta"),
        .init(title: "Asya", imageName: "category_asian", query: "asian"),
        .init(title: "Et", imageName: "category_steak", query: "steak"),
        .init(title: "Tavuk", imageName: "category_chicken", query: "chicken"),
        .init(title: "Balık", imageName: "category_fish", query: "fish"),
        .init(title: "Salata", imageName: "category_salad", query: "salad"),
        .init(title: "Tatlı", imageName: "category_dessert", query: "dessert"),
        .init(title: "Kahve", imageName: "category_coffee", query: "coffee"),
        .init(title: "Çay", imageName: "category_tea", query: "tea"),
        .init(title: "Alkol", imageName: "category_alcohol", query: "bar")
    ]
    
    init() {
        selectedCategory = categories[0]
    }
    
    func selectCategory(at index: Int) {
        guard categories.indices.contains(index) else { return }
        selectedCategory = categories[index]
    }
    
    func selectRadius(at index: Int) {
        guard [0, 1, 2, 3].contains(index) else { return }
        selectedRadiusIndex = index
    }
    
    func selectRating(at index: Int) {
        guard [0, 1, 2, 3, 4].contains(index) else { return }
        selectedRatingIndex = index
    }
    
    func selectPrice(at index: Int) {
        guard [0, 1, 2, 3, 4].contains(index) else { return }
        selectedPriceIndex = index
    }

    func makeFilter() -> PlaceFilter {
        let selected = selectedCategory

        let categoryQuery: String
        let displayCategory: String

        if selected.title == "Rastgele" {
            let randomCategory = categories
                .filter { $0.title != "Rastgele" }
                .randomElement() ?? categories[1]

            categoryQuery = randomCategory.query
            displayCategory = randomCategory.title
        } else {
            categoryQuery = selected.query
            displayCategory = selected.title
        }

        return PlaceFilter(
            category: categoryQuery,
            radius: radiusValue(for: selectedRadiusIndex),
            limit: 20,
            price: priceValue(for: selectedPriceIndex),
            minRating: ratingValue(for: selectedRatingIndex),
            openNow: nil,
            displayCategory: displayCategory
        )
    }
    
    private func radiusValue(for index: Int) -> Int {
        let values = [300, 600, 1000, 2000]
        guard values.indices.contains(index) else { return 600 }
        return values[index]
    }
    
    private func ratingValue(for index: Int) -> Double? {
        switch index {
        case 1: return 3.0
        case 2: return 3.5
        case 3: return 4.0
        case 4: return 4.5
        default: return nil
        }
    }
    
    private func priceValue(for index: Int) -> Int? {
        switch index {
        case 1: return 1
        case 2: return 2
        case 3: return 3
        case 4: return 4
        default: return nil
        }
    }
    
    func isCategorySelected(at index: Int) -> Bool {
        guard categories.indices.contains(index) else { return false }
        return selectedCategory == categories[index]
    }
    
    func isRadiusSelected(at index: Int) -> Bool {
        selectedRadiusIndex == index
    }
    
    func isRatingSelected(at index: Int) -> Bool {
        selectedRatingIndex == index
    }
    
    func isPriceSelected(at index: Int) -> Bool {
        selectedPriceIndex == index
    }
}
