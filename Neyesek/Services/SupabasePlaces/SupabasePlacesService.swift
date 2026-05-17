//
//  SupabasePlacesService.swift
//  Neyesek
//
//  Created by Faruk on 5.05.2026.
//

import Foundation
import Supabase

final class SupabasePlacesService {

    private let baseURL = "https://tdsocynckmdqedeouxxa.supabase.co/functions/v1/places"
    private let client: SupabaseClient

    init(client: SupabaseClient) {
        self.client = client
    }

    func fetchPlaces(
        lat: Double,
        lng: Double,
        category: String?
    ) async throws -> [PlacesDTO] {

        var components = URLComponents(string: baseURL)!

        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "lat", value: "\(lat)"),
            URLQueryItem(name: "lng", value: "\(lng)"),
            URLQueryItem(name: "radius", value: "600"),
            URLQueryItem(name: "type", value: placeType(for: category))
        ]

        if let category {
            queryItems.append(URLQueryItem(name: "keyword", value: keyword(for: category)))
        }

        components.queryItems = queryItems

        guard let url = components.url else {
            throw NetworkError.badURL
        }

        var request = URLRequest(url: url)

        do {
            let session = try await client.auth.session
            request.setValue("Bearer \(session.accessToken)", forHTTPHeaderField: "Authorization")

            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }

            if httpResponse.statusCode == 429 {
                throw NetworkError.statusCode(429)
            }

            guard 200...299 ~= httpResponse.statusCode else {
                throw NetworkError.statusCode(httpResponse.statusCode)
            }

            do {
                let decoded = try JSONDecoder().decode(GooglePlacesResponse.self, from: data)
                return decoded.results
            } catch {
                throw NetworkError.decoding(error)
            }

        } catch let error as NetworkError {
            throw error

        } catch {
            let nsError = error as NSError

            if nsError.domain == NSURLErrorDomain {
                switch nsError.code {
                case NSURLErrorNotConnectedToInternet,
                     NSURLErrorNetworkConnectionLost,
                     NSURLErrorTimedOut:
                    throw NetworkError.noInternet

                default:
                    throw NetworkError.invalidResponse
                }
            }

            throw NetworkError.invalidResponse
        }
    }

    private func placeType(for category: String?) -> String {
        switch category {
        case "bar": return "bar"
        case "coffee", "tea": return "cafe"
        default: return "restaurant"
        }
    }

    private func keyword(for category: String) -> String {
        switch category {
        case "burger":
            return "burger hamburger fast food"
        case "pizza":
            return "pizza italian"
        case "doner":
            return "döner doner kebab dürüm"
        case "kebab":
            return "kebap kebab ocakbaşı grill"
        case "pasta":
            return "pasta makarna italian"
        case "asian":
            return "asian sushi chinese japanese korean thai"
        case "steak":
            return "steak meat grill butcher"
        case "chicken":
            return "chicken tavuk fried chicken"
        case "fish":
            return "fish seafood balık"
        case "salad":
            return "salad healthy vegan"
        case "dessert":
            return "dessert bakery pastry waffle ice cream"
        case "coffee":
            return "coffee cafe espresso"
        case "tea":
            return "tea cafe çay"
        case "bar":
            return "bar pub cocktail beer"
        default:
            return ""
        }
    }
}
