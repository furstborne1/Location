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

    
    
    
    //MARK: TableView delegate
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell", for: indexPath)
        let descriptionLbl = cell.viewWithTag(100) as! UILabel
        descriptionLbl.text = "if you can see this"
        
        let addressLbl = cell.viewWithTag(101) as! UILabel
        addressLbl.text = "fuck you"
        return cell
    }
}
