//
//  service.swift
//  SportsTechnology
//
//  Created by Edison Aviles on 4/10/24.
//

import Foundation

class NetworkService {
    
    static func fetchAllGamesByDate(from: String, to: String) async throws -> Data {
            let urlString = "http://localhost:3001/get-games?from=\(from)&to=\(to)"
            guard let url = URL(string: urlString) else {
                throw NSError(domain: "NetworkService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
            }
            
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                throw NSError(domain: "NetworkService", code: 2, userInfo: [NSLocalizedDescriptionKey: "Invalid response or status code"])
            }
            
            return data
        }
    static func callFetchAllGamesByDate(from: String, to: String) async {
        do {
            let data = try await self.fetchAllGamesByDate(from: from, to: to)
            // Process data here, e.g., decode JSON
            print("Data received: \(data)")
        } catch {
            // Handle error here
            print("Error: \(error.localizedDescription)")
        }
    }
}
