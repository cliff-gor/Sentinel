# Sentinel

<p align="center">
    <a href="https://swiftpackageindex.com/cliff-gor/Sentinel">
        [![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fcliff-gor%2FSentinel%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/cliff-gor/Sentinel)
    </a>
    <a href="https://swiftpackageindex.com/cliff-gor/Sentinel">
       [![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fcliff-gor%2FSentinel%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/cliff-gor/Sentinel)
    </a>
    <a href="https://github.com/cliff-gor/Sentinel/releases">
        <img src="https://img.shields.io/github/v/release/cliff-gor/Sentinel?color=blue&style=flat" alt="Latest Release">
    </a>
    
    
</p>

**Sentinel** is a lightweight, zero-dependency Swift Package designed to provide drop-in network observability and chaos engineering for high-stakes iOS applications. 

Built with modern Swift Concurrency (Actors, AsyncStream) and Protocol-Oriented Programming, Sentinel allows developers to inspect network traffic and simulate infrastructure failures in real-time without altering core business logic.

## 🎯 The Problem It Solves

Testing edge cases in production-grade apps is painfully slow. Reproducing a "504 Gateway Timeout" or a "402 Payment Required" usually requires modifying backend state, toggling feature flags, or disabling your Mac's Wi-Fi. 

**Sentinel solves this by providing:**
1. **Real-time Observability:** A SwiftUI drop-in debug menu to view all incoming and outgoing network traffic directly on the device.
2. **Chaos Engineering:** A "Chaos Mode" toggle that intercepts outbound requests and forces predefined failures (e.g., simulating a failed payment) so engineers can verify UI error handling instantly.
3. **Zero-Friction Integration:** A protocol-oriented design that wraps `URLSession` invisibly.

---

## Installation

### Swift Package Manager
Add Sentinel to your `Package.swift` or via Xcode (File > Add Packages...):

```swift
dependencies: [
    .package(url: "[https://github.com/cliff-gor/Sentinel.git](https://github.com/cliff-gor/Sentinel.git)", from: "1.0.0")
]
```

---

##  Quick Start

### 1. Intercepting Network Calls

Sentinel is designed to be completely transparent to your existing networking layer. Simply replace your usage of `URLSession.shared` with `Sentinel.network`.

```swift
import Foundation
import Sentinel

class DeliveryTrackingService {
    // Before:
    // let session = URLSession.shared
    
    // After:
    let session: NetworkEngine = Sentinel.network
    
    func fetchDeliveryStatus(orderId: String) async throws -> Delivery {
        let request = URLRequest(url: URL(string: "[https://api.sendy.com/v1/deliveries/](https://api.sendy.com/v1/deliveries/)\(orderId)")!)
        
        // Sentinel automatically logs this request and checks for Chaos Mode
        let (data, _) = try await session.data(for: request)
        return try JSONDecoder().decode(Delivery.self, from: data)
    }
}
```

### 2. Presenting the Developer Sandbox (UI)

Sentinel comes with a pre-built SwiftUI dashboard. We recommend exposing this via a hidden gesture (like a long-press or shake) in your Staging/Debug builds.

```swift
import SwiftUI
import Sentinel

struct MainAppView: View {
    @State private var showDebugMenu = false
    
    var body: some View {
        HomeTabView()
            .onShake { // Or any custom gesture
                showDebugMenu.toggle()
            }
            .sheet(isPresented: $showDebugMenu) {
                // Drop in the Sentinel UI
                SentinelListView() 
            }
    }
}
```

---

##  Chaos Mode

Chaos Mode allows QA and Developers to instantly test the app's error-handling paths. When enabled via the `SentinelListView` UI, the `SentinelInterceptor` will block outbound network calls and throw a simulated error.

You can also enable it programmatically for specific UI/Integration tests:

```swift
import Sentinel

// Force the network layer to fail with a 402 Payment Required
Sentinel.enableChaosMode(true)
```

---

## Architecture

Sentinel is built for the Swift 6 era:
* **`NetworkEngine` Protocol:** Ensures strict dependency inversion.
* **`SentinelInspector` Actor:** Guarantees thread-safe logging across complex, concurrent network tasks without using legacy `NSLock` or Dispatch Queues.
* **`AsyncStream`:** Powers the real-time SwiftUI updates, ensuring the UI only renders when new data flows through the pipeline, eliminating Combine overhead.

---

## Testing

Sentinel is fully unit-tested using the modern `Swift Testing` framework. To run the suite:
1. Open `Package.swift` in Xcode.
2. Press `Command + U`.

Mock engines are provided out-of-the-box to ensure Sentinel tests do not hit live servers.


