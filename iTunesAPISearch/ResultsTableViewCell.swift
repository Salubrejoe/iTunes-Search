//
//  ResultsTableViewCell.swift
//  iTunesAPISearch
//
//  Created by Lore P on 21/02/2023.
//

import UIKit

class ResultsTableViewCell: UITableViewCell {
    var name: String?
    {
        didSet {
            // Ensure that an update is performed whenever this property changes.
            if oldValue != name {
                setNeedsUpdateConfiguration()
            }
        }
    }
    var artist: String?
    {
        didSet {
            // Ensure that an update is performed whenever this property changes.
            if oldValue != artist {
                setNeedsUpdateConfiguration()
            }
        }
    }
    var artworkImage: UIImage?
    {
        didSet {
            if oldValue != artworkImage {
                setNeedsUpdateConfiguration()
            }
        }
    }
    
    override func updateConfiguration(using state: UICellConfigurationState) {
        var content = defaultContentConfiguration().updated(for: state)

        content.text = name
        content.secondaryText = artist
        content.imageProperties.reservedLayoutSize = CGSize(width: 100.0, height: 100.0)
        if let image = artworkImage {
            content.image = image
        } else {
            // set set content's image to the system image "photo"
            content.image = UIImage(systemName: "photo")
            content.imageProperties.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 75.0)
            content.imageProperties.tintColor = .lightGray
        }
        
        self.contentConfiguration = content
    }
}
