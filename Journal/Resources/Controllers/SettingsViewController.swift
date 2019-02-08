//
//  SettingsViewController.swift
//  Journal
//
//  Created by Cagri Sahan on 5/1/18.
//  Copyright © 2018 Cagri Sahan. All rights reserved.
//

import UIKit
import JournalEntry

class SettingsViewController: UIViewController {
    
    // MARK: Variables
    let userDefaults = UserDefaults.standard
    var homeScreen: HomeViewController!
    
    // MARK: IBOutlets
    @IBOutlet weak var nameLabel: UILabel!
    
    // MARK: IBActions
    @IBAction func syncButtonTapped(_ sender: Any) {
        CloudUtilities.syncFromCloud() {
            NotificationCenter.default.post(name: NSNotification.Name("NeedsRefresh"), object: nil)
        }
    }
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameLabel.text = userDefaults.value(forKey: "UserName") as? String ?? "Hello"
    }
    
    
}
