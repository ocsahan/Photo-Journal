//
//  UnderlinedTextField.swift
//  np-challenge
//
//  Created by Cagri Sahan on 3/25/18.
//  Copyright © 2018 Cagri Sahan. All rights reserved.
//
import UIKit

class UnderlinedTextField: UITextField {
    
    // MARK: Functions
    override init(frame: CGRect) {
        super.init(frame: frame)
        initializeTextField()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initializeTextField()
    }
    
    func initializeTextField() {
        let border = CALayer()
        let borderWidth = CGFloat(2.0)
        border.borderColor = #colorLiteral(red: 0.4784313725, green: 0, blue: 0.01176470588, alpha: 1)
        border.frame = CGRect(x: 0, y: self.frame.size.height - borderWidth, width: self.frame.size.width, height: self.frame.size.height)
        border.borderWidth = borderWidth
        self.layer.addSublayer(border)
        self.layer.masksToBounds = true
    }
}
