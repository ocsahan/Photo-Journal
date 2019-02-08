//
//  ShareViewController.swift
//  PhotoShare
//
//  Created by Cagri Sahan on 5/1/18.
//  Copyright © 2018 Cagri Sahan. All rights reserved.
//

import UIKit
import Social
import JournalEntry
import Foundation

class ShareViewController: SLComposeServiceViewController {
    
    // MARK: Variables
    var entry: Entry!
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Customize a little
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.backgroundColor = #colorLiteral(red: 0.4784313725, green: 0, blue: 0.01176470588, alpha: 1)
    }
    
    override func isContentValid() -> Bool {
        // Any image will be fine.
        return true
    }

    override func didSelectPost() {
        // This is called after the user selects Post. Do the upload of contentText and/or NSExtensionContext attachments.
        if let item = self.extensionContext?.inputItems[0] as? NSExtensionItem {
            for ele in item.attachments!{
                let itemProvider = ele as! NSItemProvider
                
                if itemProvider.hasItemConformingToTypeIdentifier("public.jpeg"){
                    itemProvider.loadItem(forTypeIdentifier: "public.jpeg", options: nil, completionHandler: { (item, error) in
                        
                        var imgData: Data!
                        var metadata: [String:Any]!
                        
                        if let url = item as? URL {
                            do {
                            imgData = try Data(contentsOf: url)
                            } catch {print(error); return}
                            let imageSource = CGImageSourceCreateWithData(imgData! as CFData, nil)
                            metadata = CGImageSourceCopyPropertiesAtIndex(imageSource!, 0, nil) as! [String: Any]
                        }
                        
                        if let img = item as? UIImage {
                            imgData = UIImagePNGRepresentation(img)
                            let imageSource = CGImageSourceCreateWithData(imgData! as CFData, nil)
                            metadata = CGImageSourceCopyPropertiesAtIndex(imageSource!, 0, nil) as! [String: Any]
                        }
                        
                        let gpsInfo = metadata["{GPS}"] as! [String:Any]
                        let latitudeRef = gpsInfo["LatitudeRef"] as! String
                        let longitudeRef = gpsInfo["LongitudeRef"] as! String
                        var latitude = gpsInfo["Latitude"] as! Double
                        var longitude = gpsInfo["Longitude"] as! Double
                        
                        latitude = latitudeRef == "N" ? latitude : -latitude
                        longitude = longitudeRef == "E" ? longitude : -longitude
                        
                        let image = UIImage(data: imgData)
                        
                        let tiffInfo = metadata["{TIFF}"] as! [String:Any]
                        let dateString = tiffInfo["DateTime"] as! String
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy:MM:dd HH:mm:ss"
                        let date = dateFormatter.date(from: dateString)
                        
                        let entry = Entry(image: JournalUtilities.adjustOrientation(image!), text: self.contentText, latitude: latitude, longitude: longitude, date: date!)
                        
                        JournalUtilities.saveToDisk(entry)
                        CloudUtilities.addEntry(entry)
                        
                        NotificationCenter.default.post(name: NSNotification.Name("NeedsRefresh"), object: nil)
                    })
                }
            }
        }
        
        // Inform the host that we're done, so it un-blocks its UI.
        // Note: Alternatively you could call super's -didSelectPost, which will similarly complete the extension context.
        self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
    }

    override func configurationItems() -> [Any]! {
        // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
        return []
    }

}
