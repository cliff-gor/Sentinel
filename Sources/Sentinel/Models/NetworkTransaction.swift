//
//  NetworkTransaction.swift
//  Sentinel
//
//  Created by Cliff Gor on 01/04/2026.
//

import Foundation

/// Represents a single network request and its lifecycle.
/// Marked as `Sendable` to safely pass between background networking tasks and the MainActor UI.
public struct NetworkTransaction: Identifiable, Sendable {
    public let id: UUID
    public let request: URLRequest
    public var response: URLResponse?
    public var data: Data?
    public var error: Error?
    public let timestamp: Date

    public init(request: URLRequest) {
        self.id = UUID()
        self.request = request
        self.timestamp = Date()
    }
    
    /// A convenient helper to extract the HTTP status code for the UI
    public var statusCode: Int? {
        (response as? HTTPURLResponse)?.statusCode
    }
    
    /// A helper to quickly determine if the transaction was successful (200-299)
    public var isSuccess: Bool {
        guard let code = statusCode else { return false }
        return (200...299).contains(code)
    }
}
