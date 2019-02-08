//
//  AddTagDialogueViewController.swift
//  Journal
//
//  Created by Cagri Sahan on 4/30/18.
//  Copyright © 2018 Cagri Sahan. All rights reserved.
//

import UIKit

class AddTagDialogueViewController: UIViewController {
    
    // MARK: IBOutlets
    @IBOutlet weak var textField: UnderlinedTextField!
    
    // MARK: IBActions
    @IBAction func addButtonTapped(_ sender: Any) {
        if textField.text != "" {
            self.delegate?.addTag(self.textField.text!)
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    // MARK: Variables
    var delegate: AddTagDialogueDelegate?
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.preferredContentSize = CGSize(width: 300, height: 120)
    }
}
