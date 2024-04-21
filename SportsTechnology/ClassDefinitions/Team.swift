//
//  Team.swift
//  SportsTechnology
//
//  Created by Mukundh Balajee on 4/19/24.
//

import Foundation
import SwiftUI

struct Team: Codable {
    var winner: WinnerStatus?
    var logoURL: String
    var name: String
    var id: Int
    
    enum CodingKeys: String, CodingKey {
        case winner, logoURL = "logo", name, id
    }
    
    // Default initializer for Venues
    init(winner: WinnerStatus?, logoURL: String = "", name: String = "", id: Int = 0) {
        self.logoURL = logoURL
        self.name = name
        self.id = id
        self.winner = winner
    }
}
