//
//  Venues.swift
//  SportsTechnology
//
//  Created by Mukundh Balajee on 4/19/24.
//

import Foundation

struct Venues: Identifiable, Codable {
    var city: String
    var id: Int
    var name: String
    
    // Default initializer for Venues
    init(city: String = "", id: Int = 0, name: String = "") {
        self.city = city
        self.name = name
        self.id = id
    }
}
