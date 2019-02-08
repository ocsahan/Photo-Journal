//
//  TodayViewController.swift
//  Journal Widget
//
//  Created by Cagri Sahan on 5/3/18.
//  Copyright © 2018 Cagri Sahan. All rights reserved.
//

import UIKit
import NotificationCenter
import JournalEntry

class TodayViewController: UIViewController, NCWidgetProviding {
    
    // MARK: IBOutlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: Variables
    var digest: [String:UIImage] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        digest = JournalUtilities.loadFiveFromDisk()
        tableView.dataSource = self
    }
    
    // MARK: Functions
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        self.tableView.reloadData()
        
        completionHandler(NCUpdateResult.newData)
    }
    
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize){
        if (activeDisplayMode == NCWidgetDisplayMode.compact) {
            self.preferredContentSize = maxSize;
        } else {
            self.preferredContentSize = CGSize(width: 0, height: 400);
        }
    }
}

// MARK: Extensions
extension TodayViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return digest.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        
        // I am trying to make this as small as possible; having memory issues and widget won't load.
        // Widget only works in simulator - consumes too much memory on the phone.
        let index = indexPath.row
        let pair = Array(digest)[index]
        cell?.imageView?.image = pair.value
        cell?.textLabel?.text = pair.key
        cell?.detailTextLabel?.text = ""
        return cell!
    }
}
