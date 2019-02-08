//
//  EntryAnnotationClusterView.swift
//  Journal
//
//  Created by Cagri Sahan on 4/30/18.
//  Copyright © 2018 Cagri Sahan. All rights reserved.
//

import MapKit

class EntryAnnotationClusterView: MKMarkerAnnotationView {
    
    // MARK: Variables
    var delegate: AnnotationDelegate?
    var recordNames: [String] = []
    
    override var annotation: MKAnnotation? {
        willSet {
            guard let cluster = newValue as? MKClusterAnnotation else { return }
            glyphText = String(cluster.memberAnnotations.count)
            markerTintColor = #colorLiteral(red: 0.4823529412, green: 0.07843137255, blue: 0.0862745098, alpha: 1)
            
            let annotations = cluster.memberAnnotations.map { $0 as! EntryAnnotation }
            let sampleDelegate = annotations.first?.delegate
            delegate = sampleDelegate
            
            for item in annotations {
                recordNames.append(item.recordName)
            }
            
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

