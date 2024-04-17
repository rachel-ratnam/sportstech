//
//  service.swift
//  SportsTechnology
//
//  Created by Edison Aviles on 4/10/24.
//

import Foundation

class NetworkService {
    
    var urlString: String = "http://172.26.14.12:3001" // NodeJS server ip
    
    /* API Endpoints for NodeJS server */
    static func fetchData(query: String) async throws -> [[String: Any]] {
        guard let url = URL(string: NetworkService().urlString + query) else {
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
    
    
    /* Function wrappers for endpoint calls */
    static func fetchAllGamesByDate(from: String, to: String) async throws -> Any {
        do {
            print("In services, getting data...")
            let data = try await self.fetchData(query: "/get-games?from=\(from)&to=\(to)")
            return data
        } catch {
            // Handle error here
            print("Error: \(error.localizedDescription)")
            throw error
        }
    }
    
    static func fetchPlayerStats(team: String, player: String) async throws -> Any {
        do {
            let data = try await self.fetchData(query: "/get-player-stats/\(team)/\(player)")
            return data
        } catch {
            print("Error: \(error.localizedDescription)")
            throw error
        }
    }
    
    static func fetchAllPlayers(page: Int) async throws -> Any {
        do {
            let data = try await self.fetchData(query: "/get-all-players/\(page)")
            return data
        } catch {
            print("Error: \(error.localizedDescription)")
            throw error
        }
    }
    
    static func fetchAllTeams(page: Int) async throws -> Any {
        do {
            let data = try await self.fetchData(query: "/get-all-teams/\(page)")
            return data
        } catch {
            print("Error: \(error.localizedDescription)")
            throw error
        }
    }
    
    static func fetchTeamStats(team: String) async throws -> Any {
        do {
            let data = try await self.fetchData(query: "/get-team-stats/\(team)")
            return data
        } catch {
            print("Error: \(error.localizedDescription)")
            throw error
        }
    }
    
    static func fetchGameStats(fixtureId: Int) async throws -> Any {
        do {
            let data = try await self.fetchData(query: "/get-game-stats/\(fixtureId)")
            return data
        } catch {
            print("Error: \(error.localizedDescription)")
            throw error
        }
    }
    
    static func fetchGameEvents(fixtureId: Int) async throws -> Any {
        do {
            let data = try await self.fetchData(query: "/get-game-events/\(fixtureId)")
            return data
        } catch {
            print("Error: \(error.localizedDescription)")
            throw error
        }
    }
}
