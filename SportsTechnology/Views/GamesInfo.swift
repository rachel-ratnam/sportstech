//
//  GamesInfo.swift
//  SportsTechnology
//
//  Created by Mukundh Balajee on 4/19/24.
//

import Foundation
import UIKit
import SwiftUI

struct GamesInfo: View {
    var fixtures: [Fixture] // Fixture is a model representing a game

    var body: some View {
        ScrollView {
            VStack(spacing: 5) {
                ForEach(fixtures, id: \.id) { fixture in
                    // Create a SwiftUI view with the fixture information
                    FixtureCardView(
                        homeTeamName: fixture.teams["home"]?.name ?? "Home Team",
                        awayTeamName: fixture.teams["away"]?.name ?? "Away Team",
                        homeTeamFlag: fixture.teams["home"]?.logoURL ?? "",//Image("englandflag"),//fixture.teams["home"]?.logoURL ?? "",
                        awayTeamFlag: fixture.teams["away"]?.logoURL ?? "",//Image("iranflag"),//fixture.teams["away"]?.logoURL ?? "",
                        matchDate: fixture.date,
                        matchTime: fixture.timezone,
                        matchVenue: fixture.venue
                        )
                        .frame(width: 1000, height: 100) // Set the frame as needed
                    
                }
                .padding()
            }
        }
    }
}

struct GamesInfo_Previews: PreviewProvider {
    static var previews: some View {
        // Provide some example data to populate the preview
        GamesInfo(fixtures: [
            Fixture(id: 1, date: "21 NOV", timezone: "UTC", venue: Venues(city: "London", id: 0, name: "Stamford Stadium"), status: Status(elapsed: 90, longDescription: "FullTime", shortDescription: "FT"), teams: ["home": Team(winner: nil, logoURL: "https://media.api-sports.io/football/teams/35.png", name: "England", id: 0), "away": Team(winner: nil, logoURL: "https://media.api-sports.io/football/teams/34.png", name: "Iran", id: 1)], goals: ["home": 1, "away": 0]),
            Fixture(id: 2, date: "21 NOV", timezone: "UTC", venue: Venues(city: "London", id: 0, name: "Stamford Stadium"), status: Status(elapsed: 90, longDescription: "FullTime", shortDescription: "FT"), teams: ["home": Team(winner: nil, logoURL: "", name: "England", id: 0), "away": Team(winner: nil, logoURL: "", name: "Iran", id: 1)], goals: ["home": 1, "away": 0])
        ])
        .previewLayout(.sizeThatFits) // Adjust the size of the preview as needed
        .padding()
    }
}
