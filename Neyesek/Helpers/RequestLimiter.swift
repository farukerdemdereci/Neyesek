//
//  RequestLimiter.swift
//  Pineat
//
//  Created by Faruk on 27.04.2026.
//

import Foundation

final class RequestLimiter {

    static let shared = RequestLimiter()

    private let dailyLimit = 10
    private let countKey = "daily_google_request_count"
    private let dateKey = "daily_google_request_date"

    private static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    private init() {}

    var remainingRequests: Int {
        resetIfNeeded()
        return max(dailyLimit - currentCount(), 0)
    }

    var isLimitReached: Bool {
        remainingRequests <= 0
    }

    func canMakeRequest() -> Bool {
        resetIfNeeded()
        return currentCount() < dailyLimit
    }

    func increment() {
        resetIfNeeded()
        UserDefaults.standard.set(currentCount() + 1, forKey: countKey)
    }

    func resetForTesting() {
        UserDefaults.standard.set(0, forKey: countKey)
        UserDefaults.standard.set(formattedToday(), forKey: dateKey)
    }

    private func currentCount() -> Int {
        UserDefaults.standard.integer(forKey: countKey)
    }

    private func resetIfNeeded() {
        let today = formattedToday()
        let savedDate = UserDefaults.standard.string(forKey: dateKey)

        if savedDate != today {
            UserDefaults.standard.set(today, forKey: dateKey)
            UserDefaults.standard.set(0, forKey: countKey)
        }
    }

    private func formattedToday() -> String {
        Self.formatter.string(from: Date())
    }
}
