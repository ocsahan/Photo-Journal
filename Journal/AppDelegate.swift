//
//  AppDelegate.swift
//  Journal
//
//  Created by Cagri Sahan on 4/28/18.
//  Copyright © 2018 Cagri Sahan. All rights reserved.
//

import UIKit
import JournalEntry
import CloudKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    // MARK: Variables
    var window: UIWindow?
    
    // MARK: Functions
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        
        application.registerForRemoteNotifications()
        CloudUtilities.registerForSubscriptions()
        
        return true
    }
    
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable : Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void){
        
        let notification: CKNotification = CKNotification(fromRemoteNotificationDictionary: userInfo as! [String : NSObject])
        
        if (notification.notificationType == CKNotificationType.query) {
            let queryNotification = notification as! CKQueryNotification
            let recordID = queryNotification.recordID
            
            if let recordID = recordID {
                CloudUtilities.fetchSingleRecord(recordID: recordID, completion: {
                    NotificationCenter.default.post(name: NSNotification.Name("NeedsRefresh"), object: nil)
                    print("hudey")
                })
                
                completionHandler(.newData)
            }
            else { completionHandler(.noData) }
        }
        
    }
    
}

