//
//  service.swift
//  SportsTechnology
//
//  Created by Edison Aviles on 4/10/24.
//

import Foundation

struct GameInfo {
    var fixture: [String: Any]
    var teams: [String: Any]
    var goals: [String: Int]
}

class NetworkService {
    
    var urlString: String = "http://10.0.0.7:3001" // NodeJS server ip
    
    /* API Endpoints for NodeJS server */
    static func fetchData(query: String) async throws -> [GameInfo] {
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
    
    static func parseData(data: Data) throws -> [GameInfo] {
        var gamesInfo: [GameInfo] = []

            do {
                if let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] {
                    
                    for game in jsonObject {
                        var fixtureInfo: [String: Any] = [:]
                        var teamsInfo: [String: Any] = [:]
                        var goalsInfo: [String: Int] = [:]

                        if let fixture = game["fixture"] as? [String: Any] {
                            fixtureInfo = [
                                "id": fixture["id"] ?? "",
                                "date": fixture["date"] ?? "",
                                "timestamp": fixture["timestamp"] ?? "",
                                "venue": fixture["venue"] ?? [String: Any](),
                                "status": fixture["status"] ?? [String: Any]()
                            ]
                        }
                        
                        if let teams = game["teams"] as? [String: Any] {
                            teamsInfo = teams.reduce(into: [:]) { result, team in
                                if let teamDetails = team.value as? [String: Any] {
                                    result[team.key] = [
                                        "id": teamDetails["id"] ?? "",
                                        "name": teamDetails["name"] ?? "",
                                        "logo": teamDetails["logo"] ?? "",
                                        "winner": teamDetails["winner"] ?? false
                                    ]
                                }
                            }
                        }
                        
                        if let goals = game["goals"] as? [String: Int] {
                            goalsInfo = goals
                        }
                        
                        let gameInfo = GameInfo(fixture: fixtureInfo, teams: teamsInfo, goals: goalsInfo)
                        gamesInfo.append(gameInfo)
                    }
                } else {
                    throw NSError(domain: "NetworkService", code: 2, userInfo: [NSLocalizedDescriptionKey: "Invalid JSON structure"])
                }
            } catch {
                throw NSError(domain: "NetworkService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Error parsing JSON: \(error.localizedDescription)"])
            }
            
            return gamesInfo
    }
    
    
    /* Function wrappers for endpoint calls */
    static func fetchAllGamesByDate(from: String, to: String) async throws -> [GameInfo] {
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
