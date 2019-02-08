//
//  EntryAnnotationView.swift
//  Journal
//
//  Created by Cagri Sahan on 4/30/18.
//  Copyright © 2018 Cagri Sahan. All rights reserved.
//

import MapKit

class EntryAnnotationView: MKAnnotationView {
    
    // MARK: Variables
    var delegate: AnnotationDelegate?
    var recordNames: [String] = []
    
    override var annotation: MKAnnotation? {
        willSet {
            guard let entryAnnotation = newValue as? EntryAnnotation else { return }
            canShowCallout = true
            image = #imageLiteral(resourceName: "icons8-circled-j-filled-50")
            clusteringIdentifier = String(describing: EntryAnnotationView.self)
            delegate = entryAnnotation.delegate
            recordNames.append(entryAnnotation.recordName)
            
            // Set up callout
            canShowCallout = true
            let saveButton = UIButton(type: .custom)
            saveButton.setImage(#imageLiteral(resourceName: "icons8-back-arrow-64"), for: .normal)
            saveButton.tintColor = UIColor.white
            saveButton.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
            saveButton.backgroundColor = #colorLiteral(red: 0.4823529412, green: 0.07843137255, blue: 0.0862745098, alpha: 1)
            saveButton.addTarget(self, action: #selector(sendLocation), for: .touchUpInside)
            leftCalloutAccessoryView = saveButton
        }
    }
    
    // MARK: Functions
    @objc func sendLocation() {
        delegate?.filterFromMap(recordNames: recordNames)
    }
}
