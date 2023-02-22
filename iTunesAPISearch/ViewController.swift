//
//  ViewController.swift
//  iTunesAPISearch
//
//  Created by Lore P on 21/02/2023.
//

import UIKit

class ViewController: UIViewController, UISearchResultsUpdating {
    
    let itemController = AppleStoreItemController()
    
    
    
    var items = [AppleStoreItem]()
    
    let queryOptions = ["movie", "music", "software", "ebook"]
    
    
    
    
    // MARK: UI
    private let segmentedControl = UISegmentedControl(items: ["Movies", "Music", "Apps", "Ebook"])
    
    private let searchController: UISearchController = {
       
        let controller = UISearchController()
        controller.searchBar.placeholder = "Search the iTunes Store"
        
        return controller
    }()
    
    private let tableView: UITableView = {
       
        let table = UITableView()
        table.register(ResultsTableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
    
    
    
    // MARK: View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        navigationItem.titleView = segmentedControl
        segmentedControl.selectedSegmentIndex = 0
        
        view.addSubview(tableView)
        tableView.delegate   = self
        tableView.dataSource = self
        
        navigationItem.searchController                       = searchController
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchResultsUpdater                 = self
        navigationItem.hidesSearchBarWhenScrolling            = false
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        tableView.frame = view.bounds
    }
    
    
    
    // MARK: Configuration for the cell
    func configureCell(cell: ResultsTableViewCell, forItemAt indexPath: IndexPath) {
        
        let item = items[indexPath.row]
        
        cell.name         = item.name
        cell.artist       = item.artist
        
        
        Task {
            do {
                let url = URL(string: item.imageUrl)!
                let (data, response) = try await URLSession.shared.data(from: url)
                
                guard let httpResponse = response as? HTTPURLResponse,
                      httpResponse.statusCode == 200 else {
                    throw AppleStoreError.failedToFindImage
                }
                
                guard let image = UIImage(data: data) else {
                    throw AppleStoreError.failedToFindImage
                }
                
                    cell.artworkImage = image
                
                
            } catch {
                throw AppleStoreError.failedToFindImage
            }
        }
    }
}



// MARK: Delegate and Data Source
extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? ResultsTableViewCell else {
            print("Failure in cellRowat")
            return UITableViewCell()
        }
        
        configureCell(cell: cell, forItemAt: indexPath)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}


// MARK: Search Controller
extension ViewController {
    func updateSearchResults(for searchController: UISearchController) {
       fetchMatchingItems()
    }
    
    // MARK: Fetch Matching Items
    func fetchMatchingItems() {
        
        self.items = []
        self.tableView.reloadData()
        
        let searchTerm = navigationItem.searchController?.searchBar.text ?? ""
        let mediaType = queryOptions[segmentedControl.selectedSegmentIndex]
        
        if !searchTerm.isEmpty {
            
            // set up query dictionary
            let query = [
                "term"     : searchTerm,
                "media"    : mediaType,
                "lang"     : "en_us",
                "limit"    : "10"
            ]
            
            // use the item controller to fetch items
            // if successful, use the main queue to set self.items and reload the table view
            // otherwise, print an error to the console
            
            Task {
                do {
                    let items = try await itemController.fetchItems(matching: query)
                    self.items = items
                    self.tableView.reloadData()
                    print("data reloaded")
                    
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
    }
}

