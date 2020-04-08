//
//  LocationsVC.swift
//  Location
//
//  Created by MARC on 4/7/20.
//  Copyright © 2020 MARC. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class LocationsViewController: UITableViewController {
    var managedObjectContext:NSManagedObjectContext!
    var locations = [Location]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let fetchRequest = NSFetchRequest<Location>()
        let entity = Location.entity()
        fetchRequest.entity = entity
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        do {
            locations = try managedObjectContext.fetch(fetchRequest)
        } catch {
            coreDataDidFailSaving(error)
        }
    }
    
    
    
    //MARK: TableView delegate
    override func numberOfSections(in tableView: UITableView) -> Int {
        return locations.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell", for: indexPath) as! LocationCell
        let location = locations[indexPath.row]
        cell.configure(for: location)
        return cell
    }
}
