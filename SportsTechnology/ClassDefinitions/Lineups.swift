//
//  Lineups.swift
//  SportsTechnology
//
//  Created by Mukundh Balajee on 5/2/24.
//

import Foundation

struct Lineup: Identifiable, Codable {
    var id: Int
    var name: String
    var formation: String
    var start_XI: [Player]
    var subs: [Player]
    var coach_name: String
    var coach_photo: String
    
    // Default initializer for Venues
    init(id: Int = 0, name: String = "", formation: String = "", start_XI: [Player] = [], subs: [Player] = [], coach_name: String = "", coach_photo: String = "") {
        self.id = id
        self.name = name
        self.formation = formation
        self.start_XI = start_XI
        self.subs = subs
        self.coach_name = coach_name
        self.coach_photo = coach_photo
    }
}
