//
//  service.swift
//  SportsTechnology
//
//  Created by Edison Aviles on 4/10/24.
//

import Foundation
import SwiftUI

struct GameInfo {
    var fixture: [String: Any]
    var teams: [String: Any]
    var goals: [String: Int]
}

class NetworkService {
    
    var urlString: String = "http://10.0.0.130:3001" // NodeJS server ip
    
    /* API Endpoints for NodeJS server */
    static func fetchData(query: String) async throws -> Any {
        guard let url = URL(string: NetworkService().urlString + query) else {
            throw NSError(domain: "NetworkService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
        }
        print("Making API Call...")
        let (data, response) = try await URLSession.shared.data(from: url)
        print("API Response Received...")
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw NSError(domain: "NetworkService", code: 2, userInfo: [NSLocalizedDescriptionKey: "Invalid response or status code"])
        }
            
        if(query.hasPrefix("/get-games")){
            return try! parseFixtureInfo(data: data)
        }
        else{
            return try! parseTeamLinups(data: data)
        }
    }
    
    static func parseTeamLinups(data: Data) throws -> [Lineup]{
        var team_lineups: [Lineup] = []
        do {
            if let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] {
                for team in jsonObject {
                    var team_info: Lineup = Lineup()
                    print("Team parsing...")
                    if let info = team["team"] as? [String: Any] {
                        team_info.id = info["id"] as! Int
                        team_info.name = info["name"] as! String
                    }
                    
                    if let form = team["formation"] as? String {
                        team_info.formation = form
                    }
                    
                    if let coach = team["coach"] as? [String: Any] {
                        team_info.coach_name = coach["name"] as! String
                        team_info.coach_photo = coach["photo"] as! String
                    }
                    
                    if let array = team["startXI"] as? [[String: Any]] {
                        for element in array {
                            if let info = element["player"] as? [String: Any] {
                                var player: Player = Player()
                                
                                player.id = info["id"] as! Int
                                player.grid = info["grid"] as? String ?? ""
                                player.name = info["name"] as! String
                                player.number = info["number"] as! Int
                                player.pos = info["pos"] as! String
                                
                                team_info.start_XI.append(player)
                            }
                        }
                    } else {
                        print("Error in parsing starting XI")
                    }
                    
                    if let array = team["substitutes"] as? [[String: Any]] {
                        for element in array {
                            if let info = element["player"] as? [String: Any] {
                                var player: Player = Player()
                                
                                player.id = info["id"] as! Int
                                player.grid = info["grid"] as? String ?? ""
                                player.name = info["name"] as! String
                                player.number = info["number"] as! Int
                                player.pos = info["pos"] as! String
                                
                                team_info.subs.append(player)
                            }
                        }
                    } else {
                        print("Error in parsing substitutes")
                    }
                    
                    team_lineups.append(team_info)
                }
            } else {
                throw NSError(domain: "NetworkService", code: 2, userInfo: [NSLocalizedDescriptionKey: "Invalid JSON structure"])
            }
        } catch {
            throw NSError(domain: "NetworkService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Error parsing JSON: \(error.localizedDescription)"])
        }
        
        return team_lineups
    }
    
    static func parseFixtureInfo(data: Data) throws -> LeagueInfo {
        var leagueInfo: LeagueInfo = LeagueInfo()

            do {
                if let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] {
                    for game in jsonObject {
                        var fixtureInfo: Fixture = Fixture()

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
                        fixtureInfo.teams = ["home": Team(winner: nil), "away": Team(winner: nil)]
                        if let teams = game["teams"] as? [String: Any] {
                            if let hTeamInfo = teams["home"] as? [String: Any]{
                                print(hTeamInfo)
                                fixtureInfo.teams["home"]?.id = hTeamInfo["id"] as! Int
                                fixtureInfo.teams["home"]?.logoURL = hTeamInfo["logo"] as! String
                                fixtureInfo.teams["home"]?.name = hTeamInfo["name"] as! String
                                fixtureInfo.teams["home"]?.winner = hTeamInfo["winner"] as? WinnerStatus
                            }
                            if let aTeamInfo = teams["away"] as? [String: Any]{
                                fixtureInfo.teams["away"]?.id = aTeamInfo["id"] as! Int
                                fixtureInfo.teams["away"]?.logoURL = aTeamInfo["logo"] as! String
                                fixtureInfo.teams["away"]?.name = aTeamInfo["name"] as! String
                                fixtureInfo.teams["away"]?.winner = aTeamInfo["winner"] as? WinnerStatus
                            }
                        }
                        
                        leagueInfo.fixtures.append(fixtureInfo)
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
            return data as! LeagueInfo
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
    
    static func fetchTeamLineups(team: String) async throws -> Any {
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
    
    static func fetchTeamLineups(fixtureId: Int) async throws -> Any {
        do {
            let data = try await self.fetchData(query: "/get-team-lineups?id=\(fixtureId)")
            return data
        } catch {
            print("Error: \(error.localizedDescription)")
            throw error
        }
    }
}
