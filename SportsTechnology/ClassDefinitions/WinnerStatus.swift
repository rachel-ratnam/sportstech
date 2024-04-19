//
//  WinnerStatus.swift
//  SportsTechnology
//
//  Created by Mukundh Balajee on 4/19/24.
//

import Foundation

enum WinnerStatus: Codable {
    case won
    case lost
    case none

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let value = try? container.decode(Int.self) {
            switch value {
            case 1:
                self = .won
            case 0:
                self = .lost
            default:
                self = .none
            }
        } else {
            self = .none
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .won:
            try container.encode(1)
        case .lost:
            try container.encode(0)
        case .none:
            try container.encodeNil()
        }
    }
}
