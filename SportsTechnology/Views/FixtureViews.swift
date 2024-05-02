//
//  FixtureViews.swift
//  SportsTechnology
//
//  Created by Mukundh Balajee on 4/19/24.
//

import Foundation
import SwiftUI

// Usage in SwiftUI view
struct FixtureCardView: View {
    var homeTeamName: String
    var awayTeamName: String
    var homeTeamFlag: String
    var awayTeamFlag: String
    var matchDate: String
    var matchTime: String
    var matchVenue: Venues
    var onTap: (Int) -> Void
    var id: Int?
    
    var body: some View {
        VStack(spacing: 5) {
            Text("\(matchDate) | \(matchTime)")
                .font(.caption)
                .foregroundColor(.white)
            Text("\(matchVenue.name) | \(matchVenue.city)")
                .font(.caption)
                .foregroundColor(.white)
            HStack {
                // Home Team Flag
                AsyncImage(url: URL(string: awayTeamFlag)) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().aspectRatio(contentMode: .fit)
                    case .failure(_):
                        Image(systemName: "photo") // Or a default placeholder image
                    case .empty:
                        ProgressView()
                    @unknown default:
                        EmptyView()
                    }
                }
                .scaledToFit()
                .frame(width: 50, height: 30)
                
                Spacer()
                
                Text("VS")
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
                
                AsyncImage(url: URL(string: homeTeamFlag)) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().aspectRatio(contentMode: .fit)
                    case .failure(_):
                        Image(systemName: "photo") // Or a default placeholder image
                    case .empty:
                        ProgressView()
                    @unknown default:
                        EmptyView()
                    }
                }
                .scaledToFit()
                .frame(width: 50, height: 30)
            }
            HStack {
                Text(awayTeamName)
                    .foregroundColor(.white)
                    .font(.subheadline)
                Spacer()
                Text(homeTeamName)
                    .foregroundColor(.white)
                    .font(.subheadline)
            }
        }
        .padding()
        .background(LinearGradient(gradient: Gradient(colors: [.red, .purple]), startPoint: .top, endPoint: .bottom))
        .cornerRadius(10)
        .shadow(radius: 5)
        .frame(maxWidth: 100000)
        .onTapGesture {
            onTap(id ?? 592872)  // Call the onTap function when the card is tapped
        }
    }
}

// You should add images to your asset catalog for the flags and reference them here.
struct FixtureCardView_Previews: PreviewProvider {
    static var previews: some View {
        FixtureCardView(
            homeTeamName: "<HOME TEAM>",
            awayTeamName: "<AWAY TEAM>",
            homeTeamFlag: "https://hws.dev/paul.jpg",
            awayTeamFlag: "https://media.api-sports.io/football/teams/34.png",
            matchDate: "<DATE>",
            matchTime: "<TIME> (<TIMEZONE>)",
            matchVenue: Venues(city: "<CITY>", id: 1, name: "<STADIUM>"),
            onTap: { fixtureID in
                if fixtureID != fixtureID {
                    print("Selected Fixture ID: \(fixtureID)")
                } else {
                    print("No fixture ID available")
                }
            }
        )
        .previewLayout(.sizeThatFits)
        .padding()
    }
}
