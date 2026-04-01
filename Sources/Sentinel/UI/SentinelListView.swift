//
//  SentinelListView.swift
//  Sentinel
//
//  Created by Cliff Gor on 01/04/2026.
//

import SwiftUI

public struct SentinelListView: View {
    @StateObject private var viewModel: SentinelViewModel

    public init(inspector: SentinelInspector = Sentinel.inspector) {
        _viewModel = StateObject(wrappedValue: SentinelViewModel(inspector: inspector))
    }

    public var body: some View {
        NavigationStack {
            List(viewModel.transactions) { transaction in
                TransactionRow(transaction: transaction)
            }
            .navigationTitle("Sentinel Logs")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    // The Staff-Level Chaos Toggle
                    Toggle("Chaos Mode", isOn: Binding(
                        get: { viewModel.isChaosModeEnabled },
                        set: { _ in viewModel.toggleChaosMode() }
                    ))
                    .toggleStyle(.switch)
                    .tint(.red)
                }
            }
        }
    }
}

// MARK: - Subcomponents

/// A reusable row to display a single network transaction
struct TransactionRow: View {
    let transaction: NetworkTransaction
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                // HTTP Method Badge
                Text(transaction.request.httpMethod ?? "GET")
                    .font(.caption.bold())
                    .foregroundColor(.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.blue)
                    .cornerRadius(4)
                
                Spacer()
                
                // Status Code or Loading Indicator
                if let response = transaction.response as? HTTPURLResponse {
                    Text("\(response.statusCode)")
                        .font(.subheadline.bold())
                        .foregroundColor(color(for: response.statusCode))
                } else if transaction.error != nil {
                    Text("ERROR")
                        .font(.caption.bold())
                        .foregroundColor(.red)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.red.opacity(0.2))
                        .cornerRadius(4)
                } else {
                    ProgressView()
                        .controlSize(.mini)
                }
            }
            
            // The actual URL
            Text(transaction.request.url?.absoluteString ?? "Unknown URL")
                .font(.subheadline)
                .lineLimit(2)
            
            // Timestamp
            Text(transaction.timestamp, style: .time)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
    
    /// Determines the color based on standard HTTP status codes
    private func color(for statusCode: Int) -> Color {
        switch statusCode {
        case 200...299: return .green
        case 300...399: return .orange
        default: return .red
        }
    }
}

// MARK: - Preview
#Preview {
    SentinelListView()
}
