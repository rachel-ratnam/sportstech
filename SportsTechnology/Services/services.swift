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
    
    var urlString: String = "http://192.168.1.224:3001" // NodeJS server ip
    
    /* API Endpoints for NodeJS server */
    static func fetchData(query: String, playerId: Int = 0) async throws -> Any {
        guard let url = URL(string: NetworkService().urlString + query) else {
            throw NSError(domain: "NetworkService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
        }
        print("Making API Call...")
        let (data, response) = try await URLSession.shared.data(from: url)
        print("API Response Received...")
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw NSError(domain: "NetworkService", code: 2, userInfo: [NSLocalizedDescriptionKey: "Invalid response or status code"])
        }
        print(query)
        if(query.hasPrefix("/get-games")){
            return try! parseFixtureInfo(data: data)
        }
        else if(query.hasPrefix("/get-team-lineups")){
            return try! parseTeamLineups(data: data)
        }
        else{
            return try! parsePlayerStats(data: data, playerId: playerId)
        }
    }
    
    static func parsePlayerStats(data: Data, playerId: Int) throws -> Any {
        var player: Player = Player()
        do {
            if let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] {
                for team in jsonObject {
                    if let info = team["players"] as? [[String: Any]] {
                        for player_info in info {
                            if let ind_player = player_info["player"] as? [String: Any] {
                                if(ind_player["id"] as! Int) == playerId {
                                    player.photo = ind_player["photo"] as? String ?? ""
                                    player.id = ind_player["id"] as? Int ?? 0
                                    player.name = ind_player["name"] as? String ?? ""
                                    
                                    if let player_stats = player_info["statistics"] as? [[String: Any]] {
                                        for stat in player_stats {
                                            if let games = stat["games"] as? [String: Any] {
                                                player.stats.games.minutes = games["minutes"] as? Int ?? 0
                                                player.pos = games["position"] as? String ?? ""
                                            }
                                            
                                            if let offsides = stat["offsides"] as? Int {
                                                player.stats.offsides = offsides
                                            }
                                            
                                            if let shots = stat["shots"] as? [String: Any] {
                                                player.stats.shots.total = shots["total"] as? Int ?? 0
                                                player.stats.shots.on = shots["on"] as? Int ?? 0
                                            }
                                            
                                            if let goals = stat["goals"] as? [String: Any] {
                                                player.stats.goals.total = goals["total"] as? Int ?? 0
                                                player.stats.goals.conceded = goals["conceded"] as? Int ?? 0
                                                player.stats.goals.assists = goals["assists"] as? Int ?? 0
                                                player.stats.goals.saves = goals["saves"] as? Int ?? 0
                                            }
                                            
                                            if let passes = stat["passes"] as? [String: Any] {
                                                player.stats.passes.total = passes["total"] as? Int ?? 0
                                                player.stats.passes.key = passes["key"] as? Int ?? 0
                                                player.stats.passes.accuracy = passes["accuracy"] as? String ?? ""
                                            }
                                            
                                            if let tackles = stat["tackles"] as? [String: Any] {
                                                player.stats.tackles.total = tackles["total"] as? Int ?? 0
                                                player.stats.tackles.blocks = tackles["blocks"] as? Int ?? 0
                                                player.stats.tackles.interceptions = tackles["interceptions"] as? Int ?? 0
                                            }
                                            
                                            if let duels = stat["duels"] as? [String: Any] {
                                                player.stats.duels.total = duels["total"] as? Int ?? 0
                                                player.stats.duels.won = duels["won"] as? Int ?? 0
                                            }
                                            
                                            if let dribbles = stat["dribbles"] as? [String: Any] {
                                                player.stats.dribbles.attempts = dribbles["attempts"] as? Int ?? 0
                                                player.stats.dribbles.success = dribbles["success"] as? Int ?? 0
                                                player.stats.dribbles.past = dribbles["past"] as? Int ?? 0
                                            }
                                            
                                            if let fouls = stat["fouls"] as? [String: Any] {
                                                player.stats.fouls.drawn = fouls["drawn"] as? Int ?? 0
                                                player.stats.fouls.commited = fouls["key"] as? Int ?? 0
                                            }
                                            
                                            if let cards = stat["cards"] as? [String: Any] {
                                                player.stats.cards.yellow = cards["yellow"] as? Int ?? 0
                                                player.stats.cards.red = cards["red"] as? Int ?? 0
                                            }
                                            
                                            if let penalty = stat["penalty"] as? [String: Any] {
                                                player.stats.penalty.won = penalty["won"] as? Int ?? 0
                                                player.stats.penalty.commited = penalty["commited"] as? Int ?? 0
                                                player.stats.penalty.scored = penalty["scored"] as? Int ?? 0
                                                player.stats.penalty.missed = penalty["missed"] as? Int ?? 0
                                                player.stats.penalty.saved = penalty["saved"] as? Int ?? 0
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        
                    }
                }
            } else {
                throw NSError(domain: "NetworkService", code: 2, userInfo: [NSLocalizedDescriptionKey: "Invalid JSON structure"])
            }
        } catch {
            throw NSError(domain: "NetworkService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Error parsing JSON: \(error.localizedDescription)"])
        }
        
        return player
    }
    
    static func parseTeamLineups(data: Data) throws -> [Lineup]{
        var team_lineups: [Lineup] = []
        do {
            if let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] {
                for team in jsonObject {
                    var team_info: Lineup = Lineup()
                    print("Team parsing...")
                    if let info = team["team"] as? [String: Any] {
                        team_info.id = info["id"] as! Int
                        team_info.name = info["name"] as! String
                        team_info.logo = info["logo"] as! String
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
    
//    static func fetchTeamLineups(team: String) async throws -> Any {
//        do {
//            let data = try await self.fetchData(query: "/get-team-stats/\(team)")
//            return data
//        } catch {
//            print("Error: \(error.localizedDescription)")
//            throw error
//        }
//    }
    
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
    
    static func fetchPlayerStats(fixtureId: Int, playerId: Int) async throws -> Any {
        do {
            let data = try await self.fetchData(query: "/get-player-stats?id=\(fixtureId)", playerId: playerId)
            return data
        } catch {
            print("Error: \(error.localizedDescription)")
            throw error
        }
    }
}
