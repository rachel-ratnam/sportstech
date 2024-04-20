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
    var homeTeamFlag: Image
    var awayTeamFlag: Image
    var matchDate: String
    var matchTime: String
    var matchVenue: Venues

    var body: some View {
        VStack(spacing: 5) {
            Text("\(matchDate) | \(matchTime)")
                .font(.caption)
                .foregroundColor(.white)
            Text("\(matchVenue.name) | \(matchVenue.city)")
                .font(.caption)
                .foregroundColor(.white)
//            HStack {
//                AsyncImage(url: URL(string: awayTeamFlag)) { image in
//                    image.resizable()
//                } placeholder: {
//                    Image("englandflag")
//                }
//                .scaledToFit()
//                .frame(width: 50, height: 30)
//                
//                Spacer()
//                
//                Text("VS")
//                    .font(.headline)
//                    .foregroundColor(.white)
//                Spacer()
//                
//                AsyncImage(url: URL(string: homeTeamFlag)) { image in
//                    image.resizable()
//                } placeholder: {
//                    Image("iranflag")
//                }
//                .scaledToFit()
//                .frame(width: 50, height: 30)
//            }
            HStack {
                homeTeamFlag
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 30)
                Text("VS")
                    .font(.headline)
                    .foregroundColor(.white)
                awayTeamFlag
                    .resizable()
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
        .frame(maxWidth: 1000)
    }
}

// You should add images to your asset catalog for the flags and reference them here.
struct FixtureCardView_Previews: PreviewProvider {
    static var previews: some View {
        FixtureCardView(
            homeTeamName: "<HOME TEAM>",
            awayTeamName: "<AWAY TEAM>",
            homeTeamFlag: Image("englandflag"),
            awayTeamFlag: Image("iranflag"),
            matchDate: "<DATE>",
            matchTime: "<TIME> (<TIMEZONE>)",
            matchVenue: Venues(city: "<CITY>", id: 1, name: "<STADIUM>")
        )
        .previewLayout(.sizeThatFits)
        .padding()
    }
}
