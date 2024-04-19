//
//  Fixtures.swift
//  SportsTechnology
//
//  Created by Mukundh Balajee on 4/19/24.
//

import Foundation


struct Fixture: Codable {
    var id: Int
    var timezone: String
    var date: String
    var venue: Venues
    var status: Status
    var teams: [String: Team]
    var goals: [String: Int]
    
    // Provide a default initializer
    init(id: Int = 0, date: String = "", timezone: String = "", venue: Venues = Venues(), status: Status = Status(), teams: [String: Team] = [:], goals: [String: Int] = [:]) {
        self.id = id
        self.date = date
        self.timezone = timezone
        self.venue = venue
        self.status = status
        self.teams = teams
        self.goals = goals
    }
}
