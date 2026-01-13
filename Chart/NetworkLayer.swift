//
//  NetworkLayer.swift
//  Chart
//
//  Created by Shubham Kamdi on 1/12/26.
//

import Foundation

enum NetworkError: Error {
    case invalidURL
    case noData
    case decodingError
    case serverError(String)
}

class NetworkLayer {
    static let shared = NetworkLayer()
    
    // Inject the parser
    private let parser = JSONParser()
    
    private init() {}

    func performRequest<T: Decodable>(
        urlString: String,
        method: String = "GET",
        body: Encodable? = nil
    ) async throws -> T {
        
        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let body = body {
            request.httpBody = try? JSONEncoder().encode(body)
        }

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.serverError("Server returned status \( (response as? HTTPURLResponse)?.statusCode ?? 0)")
        }

        // --- INTEGRATION POINT ---
        // We use our parser class to handle the data transformation
        return try parser.parse(data: data)
    }
}
