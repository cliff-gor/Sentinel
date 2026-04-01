//
//  SentinelInterceptor.swift
//  Sentinel
//
//  Created by Cliff Gor on 01/04/2026.
//

import Foundation

/// A middleware component that intercepts network calls to provide observability and chaos testing.
public final class SentinelInterceptor: NetworkEngine {
    private let innerEngine: NetworkEngine
    private let inspector: SentinelInspector

    /// Injects the underlying network engine (defaults to URLSession) and the global inspector.
    public init(innerEngine: NetworkEngine = URLSession.shared, inspector: SentinelInspector) {
        self.innerEngine = innerEngine
        self.inspector = inspector
    }

    public func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        // 1. Log the outgoing request and get a unique tracking ID from the Actor
        let transactionId = await inspector.logRequest(request)

        // 2. Staff-Level Chaos Engineering
        // If Chaos Mode is enabled via the Sandbox UI, we block the request
        // and simulate a Sendy payment or infrastructure failure.
        if await inspector.getChaosMode() {
            throw NSError(domain: "Sentinel.Sendy.Chaos", code: 402, userInfo: [
                NSLocalizedDescriptionKey: "Chaos Mode Enabled: Simulated Sendy Payment Failure"
            ])
        }

        // 3. Execute the actual network call using the underlying engine
        let (data, response) = try await innerEngine.data(for: request)
        
        // 4. Log the successful response data back to the inspector so the UI updates
        await inspector.logResponse(for: transactionId, response: response, data: data)
        
        return (data, response)
    }
}
