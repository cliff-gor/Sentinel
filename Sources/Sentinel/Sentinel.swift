// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation

/// The main entry point for the Sentinel SDK.
/// Provides a clean, thread-safe API for the Sendy app to access the interceptor and debug state.
public final class Sentinel: Sendable {
    
    /// The globally shared inspector that holds all network logs and Chaos configuration.
    public static let inspector = SentinelInspector()
    
    /// The global interceptor to be injected into Sendy's network layer.
    /// By default, it wraps `URLSession.shared`.
    public static let network: SentinelInterceptor = {
        return SentinelInterceptor(innerEngine: URLSession.shared, inspector: inspector)
    }()
    
    // We make the initializer private to force developers to use the shared static instances.
    // This ensures there is only ever one "source of truth" for your logs.
    private init() {}
    
    /// A convenience method to programmatically toggle Chaos Mode from anywhere in the app.
    /// - Parameter enabled: true to simulate Sendy infrastructure failures.
    public static func enableChaosMode(_ enabled: Bool) {
        Task {
            await inspector.setChaosMode(enabled)
        }
    }
}
