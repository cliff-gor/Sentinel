import Testing
import Foundation
@testable import Sentinel

// MARK: - Mock Engine
/// A fake network engine that instantly returns a 200 Success for testing without hitting live servers.
final class MockNetworkEngine: NetworkEngine {
    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        let mockData = "{\"status\": \"success\"}".data(using: .utf8)!
        let mockResponse = HTTPURLResponse(
            url: request.url!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )!
        return (mockData, mockResponse)
    }
}

// MARK: - Test Suite
@Suite("Sentinel Interceptor Core Logic")
struct SentinelTests {
    
    @Test("Verifies that successful requests are logged into the inspector stream")
    func interceptorLogsRequestsSuccessfully() async throws {
        // 1. Setup
        let inspector = SentinelInspector()
        let mockEngine = MockNetworkEngine()
        let interceptor = SentinelInterceptor(innerEngine: mockEngine, inspector: inspector)
        
        // We use a Sendy API endpoint as our test case
        let testURL = URL(string: "https://api.sendy.com/v1/deliveries")!
        let request = URLRequest(url: testURL)
        
        // 2. Execute
        _ = try await interceptor.data(for: request)
        
        // 3. Assert
        for await logs in await inspector.transactionStream {
            #expect(logs.count == 1, "There should be exactly one logged transaction.")
            
            let firstLog = logs.first
            #expect(firstLog?.request.url?.absoluteString == "https://api.sendy.com/v1/deliveries")
            
            let httpResponse = firstLog?.response as? HTTPURLResponse
            #expect(httpResponse?.statusCode == 200)
            
            break // Exit the stream after checking the first emitted state
        }
    }
    
    @Test("Verifies that Chaos Mode forces a 402 error and blocks the real network call")
    func chaosModeBlocksNetworkCalls() async throws {
        // 1. Setup
        let inspector = SentinelInspector()
        await inspector.setChaosMode(true) // ENABLE CHAOS
        
        let mockEngine = MockNetworkEngine()
        let interceptor = SentinelInterceptor(innerEngine: mockEngine, inspector: inspector)
        
        let testURL = URL(string: "https://api.sendy.com/v1/checkout")!
        let request = URLRequest(url: testURL)
        
        // 2. Execute & Assert
        do {
            _ = try await interceptor.data(for: request)
            Issue.record("The network call succeeded, but it should have thrown a Chaos Mode error.")
        } catch {
            let nsError = error as NSError
            #expect(nsError.domain == "Sentinel.Fintech.Chaos", "Error domain should match the Chaos configuration.")
            #expect(nsError.code == 402, "Error code should be 402 Payment Required.")
        }
    }
}
