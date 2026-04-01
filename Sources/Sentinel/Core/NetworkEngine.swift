//
//  NetworkEngine.swift
//  Sentinel
//
//  Created by Cliff Gor on 01/04/2026.
//

import Foundation

/// The core protocol that allows for network abstraction.
/// By depending on this instead of URLSession directly, the app becomes highly testable and modular.
public protocol NetworkEngine: Sendable {
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}

/// Extend URLSession so it can be used as the default production engine without any extra mapping.
extension URLSession: NetworkEngine {}
