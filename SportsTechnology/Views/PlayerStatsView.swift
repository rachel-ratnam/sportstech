//
//  PlayerStatsView.swift
//  SportsTechnology
//
//  Created by Edison Aviles on 5/3/24.
//

import Foundation
import SwiftUI

import SwiftUI

struct PlayerStatsView: View {
    var player: Player
    var onClose: () -> Void  // Closure to handle closing

    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    VStack {
                        Button(action: onClose) {
                                                Label("Close", systemImage: "xmark.circle.fill")
                                                    .labelStyle(IconOnlyLabelStyle())
                                                    .font(.system(size: 14))  // Smaller font size
                                                    .padding(8)  // Smaller padding to reduce overall size
                                                    .foregroundColor(.white)
                                                    .background(Color.black.opacity(0.6))
                                                    .clipShape(Circle())
                                            }
                                            .buttonStyle(PlainButtonStyle())
                                            .padding(.leading, 10)  // Adjust padding around the button as needed
                        // Player Image
                        Spacer()
                        AsyncImage(url: URL(string: player.photo)) { image in
                            image.resizable()
                                .aspectRatio(contentMode: .fit)
                        } placeholder: {
                            Color.gray.opacity(0.3)
                                .overlay(Text("Loading Image..."))
                        }
                        .frame(width: 80, height: 80)
                        .clipShape(Circle())
                        Spacer()
                    }
                    

                    // Player Stats
                    VStack(alignment: .leading, spacing: 5) {
                        Text("\(player.number) \(player.name)")
                            .font(.title2)
                            .fontWeight(.bold)

                        Text("Statistics")
                            .font(.headline)
                            .padding(.top)

                        StatRow(label: "Appearances", value: String(player.stats.games.minutes / 90))
                        StatRow(label: "Goals", value: String(player.stats.goals.total))
                        StatRow(label: "Assists", value: String(player.stats.goals.assists))
                        StatRow(label: "Successful Dribbles", value: String(player.stats.dribbles.success))
                        StatRow(label: "Total Shots", value: String(player.stats.shots.total))
                        StatRow(label: "Shots on Target", value: String(player.stats.shots.on))
                        StatRow(label: "Passes (Accuracy)", value: "\(player.stats.passes.total) (\(player.stats.passes.accuracy))")
                    }
                    .padding(.leading, 10)

                    Spacer()
                }
                .padding()

                Spacer()
            }
            .navigationBarTitle("", displayMode: .inline)
        }
    }
}

struct StatRow: View {
    var label: String
    var value: String

    var body: some View {
        HStack {
            Text(label + ":")
                .bold()
            Spacer()
            Text(value)
        }
    }
}



struct StatView: View {
    var label: String
    var value: String

    var body: some View {
        VStack {
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
            Text(label)
                .font(.caption)
        }
    }
}

// Preview of the component
struct PlayerStatsView_Previews: PreviewProvider {
    static var previews: some View {
        PlayerStatsView(player: Player(id: 1, name: "Nicolas Pepe", number: 19, pos: "FW", grid: "1:3", photo: "https://example.com/photo.jpg")) {
            // This is an empty closure for preview purposes
        }
    }
}
