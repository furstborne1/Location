//
//  Location+CoreDataClass.swift
//  Location
//
//  Created by MARC on 4/6/20.
//  Copyright © 2020 MARC. All rights reserved.
//
//

import Foundation
import CoreData
import MapKit

@objc(Location)
public class Location: NSManagedObject, MKAnnotation {
    
    public var coordinate: CLLocationCoordinate2D  {
        return CLLocationCoordinate2DMake(latitude, longitude)
    }
    
    public var title: String? {
        if locationDescription.isEmpty {
            return "(No Description)"
        } else{
            return locationDescription
        }
    }
    
    public var subtitle: String? {
        return category
    }
    
    var hasPhoto: Bool {
        return photoID != nil
    }
    
    var photoURL: URL {
        assert(photoID != nil, "No Photo ID")
        let fileName = "Photo-\(photoID!.intValue).jpg"
        return applicationDocumentDirectory.appendingPathComponent(fileName)
    }
    
    var photoImage: UIImage? {
        return UIImage(contentsOfFile: photoURL.path)
    }
    
    class func nextPossibleID() -> Int {
        let userDefault = UserDefaults.standard
        let currentID = userDefault.integer(forKey: "PhotoID") + 1
        userDefault.set(currentID, forKey: "PhotoID")
        userDefault.synchronize()
        return currentID
    }
    
    /// this code can remove any file or folder
    func removePhotoFile() {
        if hasPhoto {
            do {
                try FileManager.default.removeItem(at: photoURL)
            } catch {
                print("error removing photo \(error.localizedDescription)")
            }
        }
    }

}
