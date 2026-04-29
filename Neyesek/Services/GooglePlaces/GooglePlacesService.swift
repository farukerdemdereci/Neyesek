//
//  GooglePlacesService.swift
//  Pineat
//
//  Created by Faruk on 23.04.2026.
//

import Foundation
import CoreLocation

final class GooglePlacesService {
    
    private let nearbyBaseURL = "https://maps.googleapis.com/maps/api/place/nearbysearch/json"
    private let detailsBaseURL = "https://maps.googleapis.com/maps/api/place/details/json"
    
    var isAPIKeyMissing: Bool {
        let key = Bundle.main.object(forInfoDictionaryKey: "GOOGLE_API_KEY") as? String ?? ""
        return key.isEmpty
            || key == "$(GOOGLE_API_KEY)"
            || key == "YOUR_GOOGLE_API_KEY"
    }
    
    private var apiKey: String {
        let key = Bundle.main.object(forInfoDictionaryKey: "GOOGLE_API_KEY") as? String ?? ""
        print("API KEY:", key.isEmpty ? "BOŞ" : "DOLU")
        return key
    }
    
    func fetchPlaces(
        userLocation: UserLocation,
        filter: PlaceFilter
    ) async throws -> [PlacesDTO] {
        var components = URLComponents(string: nearbyBaseURL)
        
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "location", value: "\(userLocation.latitude),\(userLocation.longitude)"),
            URLQueryItem(name: "radius", value: String(filter.radius ?? 600)),
            URLQueryItem(name: "key", value: apiKey),
            URLQueryItem(name: "type", value: placeType(for: filter.category))
        ]
        
        if let category = filter.category {
            queryItems.append(URLQueryItem(name: "keyword", value: keyword(for: category)))
        }
        
        if let price = filter.price {
            queryItems.append(URLQueryItem(name: "minprice", value: "1"))
            queryItems.append(URLQueryItem(name: "maxprice", value: String(price)))
        }
        
        if filter.openNow == true {
            queryItems.append(URLQueryItem(name: "opennow", value: "true"))
        }
        
        components?.queryItems = queryItems
        
        guard let url = components?.url else {
            throw NetworkError.badURL
        }
        
        let response: GooglePlacesResponse = try await request(url)
        let results = response.results
        
        if let limit = filter.limit {
            return Array(results.prefix(limit))
        }
        
        return results
    }
    
    func fetchPlaceDetails(placeId: String) async throws -> PlaceDetailsDTO {
        var components = URLComponents(string: detailsBaseURL)
        
        components?.queryItems = [
            URLQueryItem(name: "place_id", value: placeId),
            URLQueryItem(name: "fields", value: "opening_hours"),
            URLQueryItem(name: "key", value: apiKey)
        ]
        
        guard let url = components?.url else {
            throw NetworkError.badURL
        }
        
        let response: GooglePlaceDetailsResponse = try await request(url)
        return response.result
    }
    
    private func request<T: Decodable>(_ url: URL) async throws -> T {
        guard RequestLimiter.shared.canMakeRequest() else {
            throw NetworkError.statusCode(429)
        }
        
        RequestLimiter.shared.increment()
        
        do {
            print("REQUEST URL:", url.absoluteString)
            
            let (data, response) = try await URLSession.shared.data(from: url)
            
            print("HTTP STATUS:", (response as? HTTPURLResponse)?.statusCode ?? -1)
            print("RAW GOOGLE RESPONSE:\n", String(data: data, encoding: .utf8) ?? "nil")
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }
            
            guard 200...299 ~= httpResponse.statusCode else {
                throw NetworkError.statusCode(httpResponse.statusCode)
            }
            
            do {
                return try JSONDecoder().decode(T.self, from: data)
            } catch {
                print("DECODING ERROR:", error)
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
        case "bar":
            return "bar"
        case "coffee", "tea":
            return "cafe"
        default:
            return "restaurant"
        }
    }
    
    private func keyword(for category: String) -> String {
        switch category {
        case "burger":
            return "burger fast food"
        case "pizza":
            return "pizza"
        case "kebab":
            return "kebab döner"
        case "asian":
            return "asian sushi chinese japanese korean"
        case "steak":
            return "steak meat grill"
        case "chicken":
            return "chicken"
        case "fish":
            return "fish seafood"
        case "dessert":
            return "dessert bakery pastry"
        case "coffee":
            return "coffee cafe"
        case "tea":
            return "tea cafe"
        case "bar":
            return "bar pub"
        default:
            return category
        }
    }
}
