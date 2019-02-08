//
//  EntryCell.swift
//  Journal
//
//  Created by Cagri Sahan on 4/28/18.
//  Copyright © 2018 Cagri Sahan. All rights reserved.
//

import UIKit

class EntryCell: UITableViewCell {
    
    // MARK: IBOutlets
    @IBOutlet weak var entryImage: UIImageView!
    @IBOutlet weak var entryDate: UILabel!
    @IBOutlet weak var entryText: UILabel!
    @IBOutlet weak var weatherIcon: UIImageView!
    
    // MARK: Variables
    var weather: String? {
        didSet {
            if weather != "none" {
                weatherIcon.image = UIImage(named: weather!)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}
