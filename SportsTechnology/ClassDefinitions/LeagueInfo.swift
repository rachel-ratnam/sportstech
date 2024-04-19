//
//  LeagueInfo.swift
//  SportsTechnology
//
//  Created by Mukundh Balajee on 4/19/24.
//

import Foundation

struct LeagueInfo: Codable {
    var fixtures: [Fixture]
    
    init(fixtures: [Fixture] = []) {
        self.fixtures = fixtures
    }
}
