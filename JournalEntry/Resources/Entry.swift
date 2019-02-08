//
//  Entry.swift
//  JournalEntry
//
//  Created by Cagri Sahan on 4/29/18.
//  Copyright © 2018 Cagri Sahan. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit
import Photos
import CloudKit
import MapKit

public class Entry: Codable, Copyable {
    
    // MARK: Variables
    public var date: Date?
    public var text: String?
    public var image: UIImage
    public var location: CLLocation
    public var weather: String?
    public var tags: [String] = []
    public var recordName: String
    
    enum CodingKeys: CodingKey {
        case date
        case text
        case imageData
        case longitude
        case latitude
        case recordName
        case weather
        case tags
    }
    
    // MARK: Functions
    public init(fromPHAsset photoAsset: PHAsset, image: UIImage, text: String) {
        self.date = photoAsset.creationDate
        self.text = text
        self.image = JournalUtilities.resize(image: image, scale: 0.25)
        self.location = photoAsset.location!

        // Get unique record name
        self.recordName = CKRecord(recordType: "Entry").recordID.recordName
        
        // Starts async operations, blocks until done
        let queue = OperationQueue()
        
        let addVision = BlockOperation {
            JournalUtilities.guessImage(forImage: self.image, completion: { [unowned self] identifiers in
                self.tags = identifiers
            })
        }
        
        let addWeather = BlockOperation {
            JournalUtilities.getWeather(forEntry: self)
        }
        queue.addOperations([addVision,addWeather], waitUntilFinished: true)
    }
    
    public init(image: UIImage, text: String?, latitude: Double, longitude: Double, date: Date) {
        self.date = date
        self.text = text
        self.image = JournalUtilities.resize(image: image, scale: 0.25)
        self.location = CLLocation(latitude: latitude, longitude: longitude)
        
        // Get unique record name
        self.recordName = CKRecord(recordType: "Entry").recordID.recordName
        
        // Starts async operations, blocks until done
        let queue = OperationQueue()
        let addVision = BlockOperation {
            JournalUtilities.guessImage(forImage: self.image, completion: { [unowned self] identifiers in
                self.tags = identifiers
            })
        }
        let addWeather = BlockOperation {
            JournalUtilities.getWeather(forEntry: self)
        }
        queue.addOperations([addVision,addWeather], waitUntilFinished: true)
    }
    
    // Use to initialize from cloud
    public init(recordName: String, image: UIImage, text: String?, location: CLLocation, tags: [String], weather: String, date: Date) {
        self.recordName = recordName
        self.image = image
        self.text = text
        self.location = location
        self.tags = tags
        self.weather = weather
        self.date = date
    }
    
    required public init(fromObject entry: Entry) {
        self.date = entry.date
        text = entry.text
        image = entry.image.copy() as! UIImage
        location = entry.location.copy() as! CLLocation
        weather = entry.weather
        tags = entry.tags
        recordName = entry.recordName
    }
    
    
    public func encode(to encoder: Encoder) throws {
        let imageData = UIImagePNGRepresentation(image)!
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(date, forKey: .date)
        try container.encode(text, forKey: .text)
        try container.encode(imageData, forKey: .imageData)
        try container.encode(location.coordinate.longitude, forKey: .longitude)
        try container.encode(location.coordinate.latitude, forKey: .latitude)
        try container.encode(recordName, forKey: .recordName)
        try container.encode(weather, forKey: .weather)
        try container.encode(tags, forKey: .tags)
    }
    
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        date = try values.decode(Date.self, forKey: .date)
        text = try values.decode(String.self, forKey: .text)
        let imageData = try values.decode(Data.self, forKey: .imageData)
        let longitude = try values.decode(CLLocationDegrees.self, forKey: .longitude)
        let latitude = try values.decode(CLLocationDegrees.self, forKey: .latitude)
        recordName = try values.decode(String.self, forKey: .recordName)
        weather = try values.decode(String.self, forKey: .weather)
        tags = try values.decode([String].self, forKey: .tags)
        
        image = UIImage(data: imageData)!
        location = CLLocation(latitude: latitude, longitude: longitude)
    }
}
