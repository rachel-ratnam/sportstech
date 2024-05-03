//
//  Player.swift
//  SportsTechnology
//
//  Created by Mukundh Balajee on 5/2/24.
//

import Foundation

struct Player: Identifiable, Codable {
    var grid: String
    var id: Int
    var name: String
    var number: Int
    var pos: String
    var stats: Statistics = Statistics()
    
    // Default initializer for Venues
    init(id: Int = 0, name: String = "ABC", number: Int = 0, pos: String = "X", grid: String = "X:X") {
        self.grid = grid
        self.id = id
        self.name = name
        self.number = number
        self.pos = pos
        self.grid = grid
    }
}
