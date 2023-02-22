//
//  AppleStoreItemController.swift
//  iTunesAPISearch
//
//  Created by Lore P on 21/02/2023.
//

import Foundation


struct AppleStoreItemController {
    
    func fetchItems(matching query: [String: String]) async throws -> [AppleStoreItem] {
        
        var urlComponents = URLComponents(string: "https://itunes.apple.com/search")!
        urlComponents.queryItems = query.map { URLQueryItem(name: $0.key, value: $0.value) }
        
        let (data, response) = try await URLSession.shared.data(from: urlComponents.url!)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else { throw AppleStoreError.failedToContactServer }
        
        let decodedData = try JSONDecoder().decode(SearchResponse.self, from: data)
        print("items fetched")
        
        return decodedData.results
    }
}
