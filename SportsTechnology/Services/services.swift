//
//  service.swift
//  SportsTechnology
//
//  Created by Edison Aviles on 4/10/24.
//

import Foundation

class NetworkService {
    static func fetchAllGamesByDate(from: String, to: String, completion: @escaping (Result<Data, Error>) -> Void) {
        let urlString = "http://localhost:3001/get-games?from=\(from)&to=\(to)"
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                print("Invalid response or status code")
                return
            }
            
            guard let data = data else {
                print("No data received")
                return
            }
            
            completion(.success(data))
        }
        
        task.resume()
    }
}
