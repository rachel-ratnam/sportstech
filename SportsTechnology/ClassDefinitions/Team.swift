//
//  Team.swift
//  SportsTechnology
//
//  Created by Mukundh Balajee on 4/19/24.
//

import Foundation
import SwiftUI

class Team: Codable {
    var winner: WinnerStatus?
    var logoImage: UIImage?
    var logoURL: String {
        didSet {
            if !logoURL.isEmpty {
                print("Downloading Image...")
                downloadLogoImage { [weak self] image in
                    DispatchQueue.main.async {
                        self?.logoImage = image
                    }
                }
                print("Image Downloaded!")
            }
        }
    }
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
        if !logoURL.isEmpty {
            print("Downloading Image...")
            downloadLogoImage { [weak self] image in
                DispatchQueue.main.async {
                    self?.logoImage = image
                }
            }
            print("Image Downloaded!")
        }
    }
    
    func downloadLogoImage(completion: @escaping (UIImage?) -> Void) {
        guard let url = URL(string: self.logoURL) else {
            completion(nil)
            return
        }
        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard let self = self, let data = data, error == nil, let image = UIImage(data: data) else {
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            
            DispatchQueue.main.async {
                self.logoImage = image
                completion(image)
            }
        }.resume()
    }
}
