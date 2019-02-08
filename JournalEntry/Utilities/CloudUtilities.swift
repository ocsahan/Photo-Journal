//
//  File.swift
//  JournalEntry
//
//  Created by Cagri Sahan on 4/29/18.
//  Copyright © 2018 Cagri Sahan. All rights reserved.
//

import CloudKit
import Foundation

public class CloudUtilities {
    
    // MARK: Variables
    static let container = CKContainer.init(identifier: "iCloud.sahano.Journal")
    static let privateDB = container.privateCloudDatabase
    
    // MARK: Functions
    
    public static func askUserName() {
        container.requestApplicationPermission(.userDiscoverability) { (status, error) in
            CKContainer.default().fetchUserRecordID { (record, error) in
                CKContainer.default().discoverUserIdentity(withUserRecordID: record!, completionHandler: { (userID, error) in
                    if let userID = userID {
                        if let nameComponents = userID.nameComponents {
                            let name = "\(nameComponents.givenName ?? "") \(nameComponents.familyName ?? "")"
                            UserDefaults.standard.set(name, forKey: "UserName")
                        }
                    }
                })
            }
        }
        
    }
    
    public static func addEntry(_ entry: Entry) {
        let recordID = CKRecordID(recordName: entry.recordName)
        let record = CKRecord(recordType: "Entry", recordID: recordID)
        let fileManager = FileManager()
        let imageURL = fileManager.temporaryDirectory.appendingPathComponent(entry.recordName)
            let data = UIImagePNGRepresentation(entry.image)
            try! data?.write(to: imageURL)
        
        
        
        record["date"] = entry.date! as NSDate
        record["image"] = CKAsset(fileURL: imageURL)
        record["location"] = entry.location
        record["tags"] = entry.tags as NSArray
        record["text"] = entry.text! as NSString
        
        if let weather = entry.weather {
            record["weather"] = weather as NSString
        }
        privateDB.save(record) { (record, error) in
            guard error == nil else { print("Fix save!"); return }
        }
    }
    
    public static func removeEntry(_ recordName: String) {
        privateDB.delete(withRecordID: CKRecordID(recordName: recordName), completionHandler: { (record, error) in
            guard error == nil else { print("Fix delete!"); return }
        })
    }
    
    public static func modifyEntry(_ entry: Entry) {
        let recordID = CKRecordID(recordName: entry.recordName)
        privateDB.fetch(withRecordID: recordID) { record, error in
            guard error == nil else { return }
            
            if let record = record {
                let fileManager = FileManager()
                let imageURL = fileManager.temporaryDirectory.appendingPathComponent(entry.recordName)
                let data = UIImagePNGRepresentation(entry.image)
                try! data?.write(to: imageURL)
                
                record["date"] = entry.date! as NSDate
                record["image"] = CKAsset(fileURL: imageURL)
                record["location"] = entry.location
                record["tags"] = entry.tags as NSArray
                record["text"] = entry.text! as NSString
                
                if let weather = entry.weather {
                    record["weather"] = weather as NSString
                }
                privateDB.save(record) { (record, error) in
                    guard error == nil else { print("Fix modify!"); return }
                }
            }
        }
    }
    
    public static func syncFromCloud(completion: @escaping () -> Void) {
        let query = CKQuery(recordType: "Entry", predicate: NSPredicate(value: true))
        privateDB.perform(query, inZoneWith: nil) { (records, error) in
            guard error == nil else { return }
            
            JournalUtilities.deleteLocalFolder()
            
            for record: CKRecord in records! {
                let recordName = record.recordID.recordName
                let text = record["text"] as? String
                let date = record["date"] as! Date
                let location = record["location"] as! CLLocation
                let tags = record["tags"] as! [String]
                let weather = record["weather"] as! String
                let imageURL = record["image"] as! CKAsset
                
                let imageData = try! Data(contentsOf: imageURL.fileURL)
                let image = UIImage(data: imageData)
                
                let entry = Entry(recordName: recordName, image: image!, text: text, location: location, tags: tags, weather: weather, date: date)
                
                // Write entry to disk
                JournalUtilities.saveToDisk(entry)
            }
            completion()
        }
    }
    
    public static func registerForSubscriptions() {
        let identifier = "newEntry"
        let info = CKNotificationInfo()
        info.shouldSendContentAvailable = true
        info.desiredKeys = []
        
        let subscription = CKQuerySubscription(recordType: "Entry", predicate: NSPredicate(value: true), subscriptionID: identifier, options: [.firesOnRecordCreation])
        subscription.notificationInfo = info
        privateDB.save(subscription, completionHandler: { record, error in
            guard error == nil else { print("fix subscription \(error)"); return }
            print("subscription added!")
            })
    }
    
    
    public static func fetchSingleRecord(recordID: CKRecordID, completion: @escaping () -> Void) {
        privateDB.fetch(withRecordID: recordID, completionHandler: { (record, error) in
            guard error == nil else { return }
            guard let record = record else { return }
            
            let recordName = record.recordID.recordName
            let text = record["text"] as! String
            let date = record["date"] as! Date
            let location = record["location"] as! CLLocation
            let tags = record["tags"] as! [String]
            let weather = record["weather"] as! String
            let imageURL = record["image"] as! CKAsset
            
            let imageData = try! Data(contentsOf: imageURL.fileURL)
            let image = UIImage(data: imageData)
            
            let entry = Entry(recordName: recordName, image: image!, text: text, location: location, tags: tags, weather: weather, date: date)
            
            // Write entry to disk
            JournalUtilities.saveToDisk(entry)
            
            completion()
            })
    }

    
    
}
