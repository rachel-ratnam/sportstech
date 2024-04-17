//
//  service.swift
//  SportsTechnology
//
//  Created by Edison Aviles on 4/10/24.
//

import Foundation

class NetworkService {
    
    static func fetchAllGamesByDate(from: String, to: String) async throws -> [[String: Any]] {
        let urlString = "http://172.26.14.12:3001/get-games?from=\(from)&to=\(to)"
        guard let url = URL(string: urlString) else {
            throw NSError(domain: "NetworkService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
        }
        print("Making API Call...")
        let (data, response) = try await URLSession.shared.data(from: url)
        print("API Response Received...")
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw NSError(domain: "NetworkService", code: 2, userInfo: [NSLocalizedDescriptionKey: "Invalid response or status code"])
        }
            
        return try! parseData(data: data)
    }
    
    static func parseData(data: Data) throws -> [[String: Any]] {
        var fixtureInfoArray: [[String: Any]]
        // Convert the data to a JSON object
        if let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []),
           let array = jsonObject as? [[String: Any]] {
            
            // Map each game's JSON to its fixture info
            fixtureInfoArray = array.map { game -> [String: Any] in
                var filteredFixtureInfo: [String: Any] = [:]
                if let fixture = game["fixture"] as? [String: Any] {
                    filteredFixtureInfo["fixture"] = [
                                        "id": fixture["id"],
                                        "date": fixture["date"],
                                        "timestamp": fixture["timestamp"],
                                        "venue": fixture["venue"],
                                        "status": fixture["status"]
                                        // Include any other fixture details you need
                                    ]
                    return filteredFixtureInfo
                }
                return [:]
            }
        } else {
            throw NSError(domain: "NetworkService", code: 2, userInfo: [NSLocalizedDescriptionKey: "Invalid JSON structure"])
        }
        return fixtureInfoArray
    }
    
    static func callFetchAllGamesByDate(from: String, to: String) async throws -> Any {
        do {
            print("In services, getting data...")
            let data = try await self.fetchAllGamesByDate(from: from, to: to)
            // Process data here, e.g., decode JSON
//            print("Data received: \(data)")
            return data
        } catch {
            // Handle error here
            print("Error: \(error.localizedDescription)")
            throw error
        }
    }
}
