//
//  SentinelViewModel.swift
//  Sentinel
//
//  Created by Cliff Gor on 01/04/2026.
//

import Foundation
import SwiftUI

@MainActor
public final class SentinelViewModel: ObservableObject {
    @Published public var transactions: [NetworkTransaction] = []
    @Published public var isChaosModeEnabled: Bool = false

    private let inspector: SentinelInspector

    // We inject the global inspector by default
    public init(inspector: SentinelInspector = Sentinel.inspector) {
        self.inspector = inspector
        
        // Fetch the initial Chaos state
        Task {
            self.isChaosModeEnabled = await inspector.getChaosMode()
        }

        // Start listening to the AsyncStream for real-time network logs
        Task {
            for await updatedList in await inspector.transactionStream {
                self.transactions = updatedList
            }
        }
    }

    public func toggleChaosMode() {
        Task {
            let newState = !isChaosModeEnabled
            await inspector.setChaosMode(newState)
            self.isChaosModeEnabled = newState
        }
    }
}
