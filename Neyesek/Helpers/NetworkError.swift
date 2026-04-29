//
//  NetworkService.swift
//  Pineat
//
//  Created by Faruk on 25.03.2026.
//

import Foundation

enum NetworkError: Error {
    case badURL
    case invalidResponse
    case statusCode(Int)
    case decoding(Error)
    case noInternet
}

extension NetworkError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .badURL:
            return "Geçersiz URL oluşturuldu."
        case .invalidResponse:
            return "Sunucudan geçerli bir cevap alınamadı."
        case .statusCode(let code):
            if code == 429 {
                return "Günlük kullanım hakkınız doldu."
            }
            return "Sunucu hatası oluştu. Kod: \(code)"
        case .decoding(let error):
            return "Veri çözümlenemedi: \(error.localizedDescription)"
        case .noInternet:
            return "İnternet bağlantınızı kontrol edip tekrar deneyin."
        }
    }
}
