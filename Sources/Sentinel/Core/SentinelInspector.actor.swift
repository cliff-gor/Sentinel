//
//  SentinelInspector.actor.swift
//  Sentinel
//
//  Created by Cliff Gor on 01/04/2026.
//

import Foundation

/// The central, thread-safe storage for Sentinel.
/// Manages network logs and configuration states without data races.
public actor SentinelInspector {
    
    // MARK: - State
    private var transactions: [NetworkTransaction] = []
    private var isChaosModeEnabled: Bool = false
    
    // The continuation that pipes our data into the AsyncStream for the UI
    private var continuation: AsyncStream<[NetworkTransaction]>.Continuation?

    public init() {}

    // MARK: - Stream Publishing
    
    /// Provides a real-time, backpressured stream of network logs for SwiftUI.
    public var transactionStream: AsyncStream<[NetworkTransaction]> {
        AsyncStream { continuation in
            self.continuation = continuation
            // Yield the initial state immediately when someone starts listening
            continuation.yield(transactions)
        }
    }

    // MARK: - Network Logging
    
    /// Logs a new outgoing request and returns its unique UUID for future updates.
    public func logRequest(_ request: URLRequest) -> UUID {
        let transaction = NetworkTransaction(request: request)
        // Insert at the top so the newest logs appear first in the UI
        transactions.insert(transaction, at: 0)
        notify()
        return transaction.id
    }

    /// Updates an existing transaction with its response and data.
    public func logResponse(for id: UUID, response: URLResponse, data: Data) {
        if let index = transactions.firstIndex(where: { $0.id == id }) {
            transactions[index].response = response
            transactions[index].data = data
            notify()
        }
    }

    // MARK: - Chaos Engineering Configuration
    
    public func setChaosMode(_ enabled: Bool) {
        self.isChaosModeEnabled = enabled
    }

    public func getChaosMode() -> Bool {
        return isChaosModeEnabled
    }

    // MARK: - Private Helpers
    
    /// Pushes the latest state to anyone listening to the AsyncStream
    private func notify() {
        continuation?.yield(transactions)
    }
}
