//
//  Statistics.swift
//  SportsTechnology
//
//  Created by Mukundh Balajee on 5/2/24.
//

import Foundation

struct Statistics: Identifiable, Codable {
    struct Games: Codable {
        var minutes: Int = 0
    }
    
    struct Shots: Codable {
        var total: Int = 0
        var on: Int = 0
    }
    
    struct Goals: Codable {
        var total: Int = 0
        var conceded: Int = 0
        var assists: Int = 0
        var saves: Int = 0
    }
    
    struct Passes: Codable {
        var total: Int = 0
        var key: Int = 0
        var accuracy: String = ""
    }
    
    struct Tackles: Codable {
        var total: Int = 0
        var blocks: Int = 0
        var interceptions: Int = 0
    }
    
    struct Duels: Codable {
        var total: Int = 0
        var won: Int = 0
    }
    
    struct Dribbles: Codable {
        var attempts: Int = 0
        var success: Int = 0
        var past: Int = 0
    }
    
    struct Fouls: Codable {
        var drawn: Int = 0
        var comitted: Int = 0
    }
    
    struct Cards: Codable {
        var red: Int = 0
        var yellow: Int = 0
    }
    
    struct Penalties: Codable {
        var won: Int = 0
        var commited: Int = 0
        var scored: Int = 0
        var missed: Int = 0
        var saved: Int = 0
    }
    
    var id: Int
    var name: String
    var games: Games
    var offsides: Int
    var shots: Shots
    var goals: Goals
    var passes: Passes
    var tackles: Tackles
    var duels: Duels
    var dribbles: Dribbles
    var fouls: Fouls
    var cards: Cards
    var penalty: Penalties
    
    // Default initializer for Venues
    init(id: Int = 0, name: String = "", games: Games = Games(), offsides: Int = 0, shots: Shots = Shots(), goals: Goals = Goals(), passes: Passes = Passes(), tackles: Tackles = Tackles(), duels: Duels = Duels(), dribbles: Dribbles = Dribbles(), fouls: Fouls = Fouls(), cards: Cards = Cards(), penalty: Penalties = Penalties()) {
        self.id = id
        self.name = name
        self.games = games
        self.offsides = offsides
        self.shots = shots
        self.goals = goals
        self.passes = passes
        self.tackles = tackles
        self.duels = duels
        self.dribbles = dribbles
        self.fouls = fouls
        self.cards = cards
        self.penalty = penalty
    }
}
