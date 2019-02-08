//
//  EntryAnnotation.swift
//  Journal
//
//  Created by Cagri Sahan on 4/30/18.
//  Copyright © 2018 Cagri Sahan. All rights reserved.
//

import MapKit
import JournalEntry

class EntryAnnotation: NSObject, MKAnnotation {
    
    // MARK: Variables
    public var title: String?
    public var subtitle: String?
    public var coordinate: CLLocationCoordinate2D
    public var recordName: String
    public var delegate: AnnotationDelegate?
    
    // MARK: Functions
    public init(title: String?, subtitle: String?, coordinate: CLLocationCoordinate2D, recordName: String) {
        self.title = title
        self.subtitle = subtitle
        self.coordinate = coordinate
        self.recordName = recordName
    }
    
    public init(from entry: Entry) {
        self.recordName = entry.recordName
        self.title = entry.tags.first?.capitalized
        self.subtitle = entry.weather
        self.coordinate = entry.location.coordinate
    }
}
