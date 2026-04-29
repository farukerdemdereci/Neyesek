//
//  LocationViewModelTests.swift
//  PineatTests
//
//  Created by Faruk Dereci on 22.02.2026.
//

import XCTest
import UIKit
@testable import Pineat

@MainActor
final class LocationViewModelTests: XCTestCase {

    func test_fetchLocations_whenEmpty_setsStateToEmpty() async {
        // Arrange
        let service = MockLocationService()
        service.fetchResult = .success([])

        let vm = LocationViewModel(service: service)

        // Act
        await vm.fetchLocations()

        // Assert
        switch vm.state {
        case .empty:
            XCTAssertTrue(true)
        default:
            XCTFail("Expected .empty, got \(vm.state)")
        }
    }
}

// MARK: - Mock
@MainActor
final class MockLocationService: LocationServiceProtocol, UploadImageServiceProtocol {

    var fetchResult: Result<[Location], Error> = .success([])
    var uploadResult: Result<String, Error> = .success("https://fake.url/img.jpg")
    var saveResult: Result<Void, Error> = .success(())
    
    func fetchLocations() async throws -> [Location] {
        switch fetchResult {
        case .success(let items): return items
        case .failure(let err): throw err
        }
    }
    
    func uploadImage(image: UIImage) async throws -> String {
        switch uploadResult {
        case .success(let url): return url
        case .failure(let err): throw err
        }
    }
    
    func saveLocation(title: String, description: String, latitude: Double, longitude: Double, image_url: String?) async throws {
        switch saveResult {
        case .success: return
        case .failure(let err): throw err
            
        }
    }
}
