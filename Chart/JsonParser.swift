//
//  JsonParser.swift
//  Chart
//
//  Created by Shubham Kamdi on 1/12/26.
//

import Foundation

class JSONParser {
    private let decoder: JSONDecoder

    init(decoder: JSONDecoder = JSONDecoder()) {
        self.decoder = decoder
        // Example: Handle snake_case from APIs (e.g., first_name -> firstName)
        self.decoder.keyDecodingStrategy = .convertFromSnakeCase
    }

    func parse<T: Decodable>(data: Data) throws -> T {
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            print("Decoding Error: \(error)")
            throw NetworkError.decodingError
        }
    }
}

struct DoubleResponse: Codable {
    let success: Bool
    let count: Int
    let values: [Double]
}
