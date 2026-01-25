//
//  ChartViewModel.swift
//  Chart
//
//  Created by Shubham Kamdi on 1/12/26.
//

import Foundation
import Combine

class ChartViewModel: ObservableObject {
    
    struct ChartState {
        var values: [Double] = []
        var isLoading: Bool = false
        var errorMessage: String? = nil
    }
    
    // Make the state publishable
    @Published var state = ChartState()
    
    func fetchData() async {
        // Start Loading
        state.isLoading = true
        state.errorMessage = nil
        
        do {
            let result: DoubleResponse = try await NetworkLayer.shared.performRequest(
                urlString: "http://localhost:3006/api/doubles"
            )
            
            // Update state with success
            state.values = result.values
            state.isLoading = false
            print("Data Fetched and loading UI with: \(result.values.count)")
        } catch {
            // Update state with error
            state.isLoading = false
            state.errorMessage = "Failed to load data: \(error.localizedDescription)"
            print("Request failed: \(error)")
        }
    }
}
