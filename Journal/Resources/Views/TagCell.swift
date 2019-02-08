//
//  TagCell.swift
//  Journal
//
//  Created by Cagri Sahan on 4/29/18.
//  Copyright © 2018 Cagri Sahan. All rights reserved.
//

import UIKit

class TagCell: UICollectionViewCell {
    
    // MARK: IBOutlets
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var tagText: UILabel!
    
    // MARK: IBActions
    @IBAction func closeButtonTapped(_ sender: Any) {
        delegate?.deleteCell(self)
    }
    
    // MARK: Variables
    var delegate: TagCellDelegate?
    
    var isEditing: Bool =  false {
        didSet {
            closeButton.isHidden = !isEditing
        }
    }
    // MARK: Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        
        closeButton.isHidden = true
    }

}
