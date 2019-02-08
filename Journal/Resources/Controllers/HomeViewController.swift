//
//  ViewController.swift
//  Journal
//
//  Created by Cagri Sahan on 4/28/18.
//  Copyright © 2018 Cagri Sahan. All rights reserved.
//

import UIKit
import JournalEntry

class HomeViewController: UIViewController {
    
    // MARK: IBOutlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: Variables
    var entries: [Entry] = []
    var searchFilter: [Entry] = []
    let userDefaults = UserDefaults.standard
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up observer
        NotificationCenter.default.addObserver(self, selector: #selector(refresh), name: NSNotification.Name("NeedsRefresh"), object: nil)
        
        // Set up tableview
        tableView.dataSource = self
        //tableView.delegate = self
        
        // Set up search controller
        let searchController = UISearchController(searchResultsController: nil) // Search Controller
        navigationItem.hidesSearchBarWhenScrolling = false
        
        searchController.searchBar.barStyle = .black
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchResultsUpdater = self
        searchController.searchBar.placeholder = "Search Tags"
        searchController.hidesNavigationBarDuringPresentation = false
        
        definesPresentationContext = true
        navigationItem.searchController = searchController
        
        // Load all entries
        entries = JournalUtilities.loadAllFromDisk()
        searchFilter = entries
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
        
        if userDefaults.value(forKey: "UserName") == nil {
            CloudUtilities.askUserName()
        }
    }
    
    // MARK: Functions
    func newEntryAdded(added newEntry: Entry) {
        entries.append(newEntry)
        tableView.reloadData()
    }
    
    @objc func refresh() {
        print("refresh called")
        entries = JournalUtilities.loadAllFromDisk()
        searchFilter = entries
        DispatchQueue.main.async { [unowned self] in
            self.tableView.reloadData()
        }
    }
    
    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addEntry" {
            let childVC = segue.destination as! AddScreenViewController
            childVC.homeScreenVC = self
        }
        else if segue.identifier == "editEntry" {
            let childVC = segue.destination as! AddScreenViewController
            childVC.homeScreenVC = self
            let cell = sender as! EntryCell
            let entry = searchFilter[(tableView.indexPath(for: cell)?.row)!]
            childVC.editingEntry = entry.copy()
        }
        else if segue.identifier == "mapSegue" {
            let childVC = segue.destination as! MapViewController
            var annotations: [EntryAnnotation] = []
            for item in entries {
                let annotation = EntryAnnotation(from: item)
                annotations.append(annotation)
            }
            childVC.annotations = annotations
            childVC.delegate = self
        }
        else if segue.identifier == "settingsSegue" {
            let childVC = segue.destination as! SettingsViewController
            childVC.homeScreen = self
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: Extensions
extension HomeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchFilter.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EntryCell") as! EntryCell
        let entry = searchFilter[indexPath.row]
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM d, yyyy"
        let dateString = dateFormatter.string(from: entry.date!)
        
        cell.entryImage.image = JournalUtilities.resize(image: entry.image, scale: 0.1)
        cell.entryDate.text = dateString
        cell.entryText.text = entry.text
        cell.weather = entry.weather
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            let recordName = searchFilter[indexPath.row].recordName
            searchFilter.remove(at: indexPath.row)
            entries = entries.filter { $0.recordName != recordName }
            tableView.deleteRows(at: [indexPath], with: .automatic)
            JournalUtilities.deleteEntry(recordName)
            CloudUtilities.removeEntry(recordName)
        }
    }
}

extension HomeViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        if let term = searchController.searchBar.text {
            if term == "" {
                searchFilter = entries
            }
            else {
                searchFilter = entries.filter { JournalUtilities.entryHasMatchingTag(entry: $0, matchesTag: term) }
            }
        }
        tableView.reloadData()
    }
}

