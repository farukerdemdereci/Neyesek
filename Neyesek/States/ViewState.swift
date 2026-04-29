//
//  ViewState.swift
//  Pineat
//
//  Created by Faruk Dereci on 8.02.2026.
//

import Foundation

enum ViewState<T> {
    case idle
    case loading
    case success(T)
    case empty
    case error(Error)
}
