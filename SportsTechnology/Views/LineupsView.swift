//
//  LineupsView.swift
//  SportsTechnology
//
//  Created by Edison Aviles on 5/2/24.
//

import Foundation
import SwiftUI

struct PlayerView: View {
    var player: Player
    var action: () -> Void  // Add an action to handle taps
    
    var body: some View {
        VStack {
            Text("\(player.number)")
                .fontWeight(.bold)
                .font(.system(size: 12))
            Text(player.name)
                .font(.system(size: 10))
                .lineLimit(1)
                .frame(maxWidth: 60)
            Text(player.pos)
                .font(.system(size: 8))
                .foregroundColor(.secondary)
        }
        .padding(4)
        .frame(width: 70, height: 60)
        .background(Color.blue.opacity(0.75))
        .cornerRadius(6)
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(Color.white, lineWidth: 1)
        )
        .onTapGesture {
            action()
        }
    }
}

struct FieldView: View {
    var lineup: Lineup
    var home: Bool
    @Binding var selectedPlayer: Player?  // Binding to handle selected player

    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            let rows = 5
            let columns = 5
            VStack {
                HStack {
                    if home {  // Left alignment for the home team
                        HStack(spacing: 10) {
                            AsyncImage(url: URL(string: lineup.logo)) { image in
                                image.resizable()
                            } placeholder: {
                                Color.gray.frame(width: 30, height: 30)  // Placeholder while loading or if the URL is invalid
                            }
                            .frame(width: 30, height: 30)
                            .clipShape(Circle())
                            
                            Text(lineup.name)
                                .fontWeight(.bold)
                        }
                    } else {  // Right alignment for the away team
                        HStack(spacing: 10) {
                            Text(lineup.name)
                                .fontWeight(.bold)
                            
                            AsyncImage(url: URL(string: lineup.logo)) { image in
                                image.resizable()
                            } placeholder: {
                                Color.gray.frame(width: 30, height: 30)  // Placeholder while loading or if the URL is invalid
                            }
                            .frame(width: 30, height: 30)
                            .clipShape(Circle())
                        }
                    }
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Color.clear)
                .cornerRadius(8)
                .shadow(radius: 3)
                .offset(y: -100)
                HStack(alignment: .center, spacing: 10) {
                    if !home {
                        Spacer()
                    }
                    
                    let filledColumns = Set(lineup.start_XI.map { $0.grid.split(separator: ":").last! }).count
                    let columnWidth = width / CGFloat(filledColumns)
                    
                    ForEach(0..<rows, id: \.self) { index in
                        let row = home ? index : columns - 1 - index
                        VStack {
                            Spacer()
                            ForEach(0..<columns, id: \.self) { colIndex in
                                let column = home ? colIndex : columns - 1 - colIndex
                                let gridIndex = "\(row + 1):\(column + 1)"
                                if let player = lineup.start_XI.first(where: { $0.grid == gridIndex }) {
                                    PlayerView(player: player) {
                                        self.selectedPlayer = player
                                    }
                                } else {
                                    Spacer()  // Empty space for no player in this grid position
                                }
                            }
                            Spacer()
                        }
                        .frame(height: columnWidth)
                    }
                    
                    if home {
                        Spacer()
                    }
                }
            }
            .frame(width: width, height: height)
        }
    }
}


struct MatchView: View {
    var homeLineup: Lineup
    var awayLineup: Lineup
    @State private var selectedPlayer: Player?  // State to track selected player

    var body: some View {
        ZStack(alignment: .top){
            // Background image
            Image("soccer_pitch")
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
                .offset(y: -28)
            HStack(spacing: 20) {
                FieldView(lineup: homeLineup, home: true, selectedPlayer: $selectedPlayer)
                FieldView(lineup: awayLineup, home: false, selectedPlayer: $selectedPlayer)
            
            }
        }
        .sheet(item: $selectedPlayer) { player in
            PlayerStatsView(player: player) {
                self.selectedPlayer = nil  // This will close the modal
            }
        }
    }
}



struct MatchView_Previews: PreviewProvider {
    static var previews: some View {
        MatchView(
            homeLineup: Lineup(id: 1, name: "Chelsea", formation: "4-3-3", start_XI: [
                Player(id: 1, name: "Mendy", number: 1, pos: "GK", grid: "1:1"),
                Player(id: 2, name: "James", number: 2, pos: "RB", grid: "2:4"),
                Player(id: 3, name: "Silva", number: 6, pos: "CB", grid: "2:3"),
                Player(id: 4, name: "Rudiger", number: 4, pos: "CB", grid: "2:2"),
                Player(id: 5, name: "Chilwell", number: 21, pos: "LB", grid: "2:1"),
                Player(id: 6, name: "Kante", number: 7, pos: "CM", grid: "3:3"),
                Player(id: 7, name: "Jorginho", number: 5, pos: "CM", grid: "3:2"),
                Player(id: 8, name: "Mount", number: 19, pos: "CM", grid: "3:1"),
                Player(id: 9, name: "Havertz", number: 29, pos: "RW", grid: "4:3"),
                Player(id: 10, name: "Werner", number: 11, pos: "ST", grid: "4:2"),
                Player(id: 11, name: "Pulisic", number: 10, pos: "LW", grid: "4:1")
            ], subs: [], coach_name: "Pochettino", coach_photo: ""),
            awayLineup: Lineup(id: 2, name: "Tottenham", formation: "4-4-2", start_XI: [
                Player(id: 12, name: "Lloris", number: 1, pos: "GK", grid: "1:1"),
                Player(id: 13, name: "Doherty", number: 2, pos: "RB", grid: "2:4"),
                Player(id: 14, name: "Sanchez", number: 6, pos: "CB", grid: "2:3"),
                Player(id: 15, name: "Dier", number: 15, pos: "CB", grid: "2:2"),
                Player(id: 16, name: "Reguilon", number: 3, pos: "LB", grid: "2:1"),
                Player(id: 17, name: "Hojbjerg", number: 5, pos: "CM", grid: "3:3"),
                Player(id: 18, name: "Winks", number: 8, pos: "CM", grid: "3:2"),
                Player(id: 19, name: "Moura", number: 27, pos: "RW", grid: "3:4"),
                Player(id: 20, name: "Kane", number: 10, pos: "ST", grid: "4:1"),
                Player(id: 21, name: "Son", number: 7, pos: "LW", grid: "3:1"),
                Player(id: 22, name: "Bergwijn", number: 23, pos: "ST", grid: "4:2")
            ], subs: [], coach_name: "Postecoglou", coach_photo: "")
        )
        .previewLayout(.fixed(width: 1200, height: 400))
    }
}
