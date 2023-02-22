//
//  AppleStoreItem.swift
//  iTunesAPISearch
//
//  Created by Lore P on 21/02/2023.
//

import UIKit

extension Data {
    func prettyPrintedJSON() {
        guard let jsonObject = try? JSONSerialization.jsonObject(with: self, options: []),
              let jsonData = try? JSONSerialization.data(withJSONObject: jsonObject, options: [.prettyPrinted]),
              let prettyJson = String(data: jsonData, encoding: .utf8) else {
            print("Failed to read Json object")
            return
        }
        
        print(prettyJson)
    }
}

struct SearchResponse: Codable {
    var results: [AppleStoreItem]
}

struct AppleStoreItem: Codable {
    var name        : String
    var artist      : String
    var kind        : String
    var description : String
    var imageUrl    : String
    
    enum CodingKeys: String, CodingKey {
        case name       = "trackName"
        case artist     = "artistName"
        case kind
        case description
        case imageUrl   = "artworkUrl100"
    }
    
    enum AdditionalKeys: CodingKey {
        case longDescription
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        name     = try values.decode(String.self, forKey: CodingKeys.name)
        artist   = try values.decode(String.self, forKey: CodingKeys.artist)
        kind     = try values.decode(String.self, forKey: CodingKeys.kind)
        imageUrl = try values.decode(String.self, forKey: CodingKeys.imageUrl)
        
        if let description = try? values.decode(String.self, forKey: CodingKeys.description) {
            self.description = description
        } else {
            let additionalValues = try decoder.container(keyedBy: AdditionalKeys.self)
            
            description = (try? additionalValues.decode(String.self, forKey: AdditionalKeys.longDescription)) ?? ""
        }
    }
}

enum AppleStoreError: Error, LocalizedError {
    case failedToContactServer
    case failedToFindImage
}
