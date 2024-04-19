//
//  Status.swift
//  SportsTechnology
//
//  Created by Mukundh Balajee on 4/19/24.
//

import Foundation

struct Status: Codable {
    var elapsed: Int
    var longDescription: String
    var shortDescription: String
    
    // Default initializer for Status
    init(elapsed: Int = 0, longDescription: String = "", shortDescription: String = "") {
        self.elapsed = elapsed
        self.longDescription = longDescription
        self.shortDescription = shortDescription
    }
    
    enum CodingKeys: String, CodingKey {
        case elapsed, longDescription = "long", shortDescription = "short"
    }
}
