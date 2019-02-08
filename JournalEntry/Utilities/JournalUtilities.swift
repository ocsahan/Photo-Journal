//
//  JournalUtilities.swift
//  JournalEntry
//
//  Created by Cagri Sahan on 4/29/18.
//  Copyright © 2018 Cagri Sahan. All rights reserved.
//

import Foundation
import CoreML
import Vision
import MapKit


public class JournalUtilities {
    
    // MARK: Variables
    static let weatherAPIKey = "76fa51ddfbcf8dfc188aa9d8e85bc115"
    static let fileManager = FileManager.default
    static let directory = fileManager.containerURL(forSecurityApplicationGroupIdentifier: "group.sahano.Journal")
    static let storageDirectory = directory!.appendingPathComponent("Entries")
    
    // MARK: Functions
    private init() {} // This is not needed.
    
    public static func getWeather(forEntry entry: Entry) {
        let path = "https://api.darksky.net/forecast/\(weatherAPIKey)/\(entry.location.coordinate.latitude),\(entry.location.coordinate.longitude),\(Int(entry.date!.timeIntervalSince1970))?exclude=hourly,minutely,daily,flags,alerts"
        let url = URL(string: path)!
        let session = URLSession.shared
        let task = session.dataTask(with: url) { data, response, error in
            guard error == nil else { entry.weather = "unavailable"; return }
            guard data != nil else { entry.weather = "unavailable"; return }
            
            let decoder = JSONDecoder()
            do {
            let report = try decoder.decode(Report.self, from: data!)
            entry.weather = report.currently.icon
            } catch { entry.weather = "unavailable" }
            
        }
        task.resume()
    }
    
    // Atribution: https://www.raywenderlich.com/164213/coreml-and-vision-machine-learning-in-ios-11-tutorial
    public static func guessImage(forImage image: UIImage, completion: @escaping ([String]) -> ()) {
        guard let model = try? VNCoreMLModel(for: GoogLeNetPlaces().model) else { return }
        guard let ci = CIImage(image: image) else { return }
        let request = VNCoreMLRequest(model: model) { request, error in
            guard let results = request.results as? [VNClassificationObservation] else { return }
            
            // Return the first five tags
            completion(results.prefix(5).map { $0.identifier })
        }
        
        let handler = VNImageRequestHandler(ciImage: ci)
        DispatchQueue.global(qos: .userInteractive).sync {
            do {
                try handler.perform([request])
            } catch { return }
        }
    }
    
    public static func saveToDisk(_ entry: Entry) {
        let encoder = JSONEncoder()
        let data = try! encoder.encode(entry)
        
        try? fileManager.createDirectory(at: storageDirectory, withIntermediateDirectories: false, attributes: nil)
        let fileURL = storageDirectory.appendingPathComponent(entry.recordName)
        try! data.write(to: fileURL)
    }
    
    public static func loadAllFromDisk() -> [Entry] {
        try? fileManager.createDirectory(at: storageDirectory, withIntermediateDirectories: false, attributes: nil)
        let files = try! fileManager.contentsOfDirectory(at: storageDirectory, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
        
        let decoder = JSONDecoder()
        var entries: [Entry] = []
        
        for item in files {
            let data = try! Data(contentsOf: item)
            let entry = try! decoder.decode(Entry.self, from: data)
            entries.append(entry)
        }
        return entries
    }
    
    public static func deleteEntry(_ recordName: String) {
        let fileName = storageDirectory.appendingPathComponent(recordName)
        try? fileManager.removeItem(at: fileName)
    }
    
    public static func entryHasMatchingTag(entry: Entry, matchesTag tag: String) -> Bool {
        for entry in entry.tags {
            if entry.range(of: tag, options: .caseInsensitive) != nil {
                return true
            }
        }
        return false
    }
    
    public static func deleteLocalFolder() {
        try? fileManager.removeItem(at: storageDirectory)
    }
    
    // Today widget will use this
    public static func loadFiveFromDisk() -> [String:UIImage] {
        try? fileManager.createDirectory(at: storageDirectory, withIntermediateDirectories: false, attributes: nil)
        let files = try! fileManager.contentsOfDirectory(at: storageDirectory, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
        
        let decoder = JSONDecoder()
        var entries: [String:UIImage] = [:]
        
        for item in files.prefix(5) {
            let data = try! Data(contentsOf: item)
            let entry = try! decoder.decode(Entry.self, from: data)
            let image = resize(image: entry.image, scale: 0.01)
            let text = entry.text ?? ""
            entries[text] = image
        }
        return entries
    }
    
    public static func resize(image: UIImage, scale: CGFloat) -> UIImage {
        let size = image.size.applying(CGAffineTransform(scaleX: scale,y: scale))
        let hasAlpha = true
        
        // Automatically use scale factor of main screen
        let scale: CGFloat = 0.0
        
        UIGraphicsBeginImageContextWithOptions(size, !hasAlpha, scale)
        image.draw(in: CGRect(origin: CGPoint.zero, size: size))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return scaledImage!
    }
    
    // Attribution: https://iosdevcenters.blogspot.com/2017/04/image-orientation-before-upload-on.html
    public static func adjustOrientation(_ src:UIImage) -> UIImage {
        if src.imageOrientation == UIImageOrientation.up {
            return src
        }
        var transform: CGAffineTransform = CGAffineTransform.identity
        switch src.imageOrientation {
        case UIImageOrientation.down, UIImageOrientation.downMirrored:
            transform = transform.translatedBy(x: src.size.width, y: src.size.height)
            transform = transform.rotated(by: CGFloat(Double.pi))
            break
        case UIImageOrientation.left, UIImageOrientation.leftMirrored:
            transform = transform.translatedBy(x: src.size.width, y: 0)
            transform = transform.rotated(by: CGFloat(Double.pi / 2))
            break
        case UIImageOrientation.right, UIImageOrientation.rightMirrored:
            transform = transform.translatedBy(x: 0, y: src.size.height)
            transform = transform.rotated(by: CGFloat(-Double.pi / 2))
            break
        case UIImageOrientation.up, UIImageOrientation.upMirrored:
            break
        }
        
        switch src.imageOrientation {
        case UIImageOrientation.upMirrored, UIImageOrientation.downMirrored:
            transform.translatedBy(x: src.size.width, y: 0)
            transform.scaledBy(x: -1, y: 1)
            break
        case UIImageOrientation.leftMirrored, UIImageOrientation.rightMirrored:
            transform.translatedBy(x: src.size.height, y: 0)
            transform.scaledBy(x: -1, y: 1)
        case UIImageOrientation.up, UIImageOrientation.down, UIImageOrientation.left, UIImageOrientation.right:
            break
        }
        
        let ctx:CGContext = CGContext(data: nil, width: Int(src.size.width), height: Int(src.size.height), bitsPerComponent: (src.cgImage)!.bitsPerComponent, bytesPerRow: 0, space: (src.cgImage)!.colorSpace!, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
        
        ctx.concatenate(transform)
        
        switch src.imageOrientation {
        case UIImageOrientation.left, UIImageOrientation.leftMirrored, UIImageOrientation.right, UIImageOrientation.rightMirrored:
            ctx.draw(src.cgImage!, in: CGRect(x: 0, y: 0, width: src.size.height, height: src.size.width))
            break
        default:
            ctx.draw(src.cgImage!, in: CGRect(x: 0, y: 0, width: src.size.width, height: src.size.height))
            break
        }
        
        let cgimg:CGImage = ctx.makeImage()!
        let img:UIImage = UIImage(cgImage: cgimg)
        
        return img
    }
    
}
