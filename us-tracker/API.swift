//
//  API.swift
//  us-tracker
//
//  Created by Jason Morales on 8/15/24.
//

import Foundation

enum APIErrors: Error {
    case InvalidUrl
    case InvalidResponse
    case TeamsListMissing
    case PlayersListMissing
}

struct API {
    
    func fetch<T:Decodable>(url: String) async throws -> T {
        guard let url = URL(string: url) else {
            throw APIErrors.InvalidUrl
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw APIErrors.InvalidResponse
        }
                
        return try JSONDecoder().decode(T.self, from: data)
    }
}
