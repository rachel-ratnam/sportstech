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
    
    var urlString: String = "http://192.168.1.224:3001" // NodeJS server ip
    
    /* API Endpoints for NodeJS server */
    static func fetchData(query: String) async throws -> LeagueInfo {
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
    
    static func parseData(data: Data) throws -> LeagueInfo {
        var leagueInfo: LeagueInfo = LeagueInfo()

            do {
                if let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] {
                    
                    for game in jsonObject {
                        var fixtureInfo: Fixture = Fixture()
                        var homeTeam: Team = Team(winner: nil)
                        var awayTeam: Team = Team(winner: nil)

                        if let fixture = game["fixture"] as? [String: Any] {
                            fixtureInfo.id = fixture["id"] as! Int
                            fixtureInfo.date = fixture["date"] as! String
                            fixtureInfo.timezone = fixture["timezone"] as! String
                            
                            if let venueInfo = fixture["venue"] as? [String: Any] {
                                fixtureInfo.venue = Venues()
                                fixtureInfo.venue.city = venueInfo["city"] as! String
                                fixtureInfo.venue.name = venueInfo["name"] as! String
                                fixtureInfo.venue.id = venueInfo["id"] as! Int
                            }
                            
                            if let gameStatus = fixture["status"] as? [String: Any] {
                                fixtureInfo.status = Status()
                                fixtureInfo.status.longDescription = gameStatus["long"] as! String
                                fixtureInfo.status.shortDescription = gameStatus["short"] as! String
                                fixtureInfo.status.elapsed = gameStatus["elapsed"] as! Int
                            }
                        }
                        
                        if let goals = game["goals"] as? [String: Int] {
                            fixtureInfo.goals = goals
                        }
                        
                        if let teams = game["teams"] as? [String: Any] {
                            if let hTeamInfo = teams["home"] as? [String: Any]{
                                homeTeam.id = hTeamInfo["id"] as! Int
                                homeTeam.logoURL = hTeamInfo["logo"] as! String
                                homeTeam.name = hTeamInfo["name"] as! String
                                homeTeam.winner = hTeamInfo["winner"] as? WinnerStatus
                            }
                            if let aTeamInfo = teams["away"] as? [String: Any]{
                                awayTeam.id = aTeamInfo["id"] as! Int
                                awayTeam.logoURL = aTeamInfo["logo"] as! String
                                awayTeam.name = aTeamInfo["name"] as! String
                                awayTeam.winner = aTeamInfo["winner"] as? WinnerStatus
                            }
                            fixtureInfo.teams = ["home": homeTeam, "away": awayTeam]
                        }
                        
                        leagueInfo.fixtures.append(fixtureInfo)
                        //let gameInfo = GameInfo(fixture: fixtureInfo, teams: teamsInfo, goals: goalsInfo)
                        //gamesInfo.append(gameInfo)
                    }
                } else {
                    throw NSError(domain: "NetworkService", code: 2, userInfo: [NSLocalizedDescriptionKey: "Invalid JSON structure"])
                }
            } catch {
                throw NSError(domain: "NetworkService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Error parsing JSON: \(error.localizedDescription)"])
            }
            
            return leagueInfo
    }
    
    
    /* Function wrappers for endpoint calls */
    static func fetchAllGamesByDate(from: String, to: String) async throws -> LeagueInfo {
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
