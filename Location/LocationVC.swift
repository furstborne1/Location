//
//  LocationVC.swift
//  Location
//
//  Created by MARC on 4/5/20.
//  Copyright © 2020 MARC. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    return formatter
}()

class LocationVC: UITableViewController {
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    //MARK:- VARIABLES
    var coordinates = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    var placeMark: CLPlacemark?
    var categoryName = "No Category"
    var managedObjectContext: NSManagedObjectContext!
    var date = Date()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateLocationLabel()
        dateLabel.text = format(date: date)
        /// hide keyboard...
        let gesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        gesture.cancelsTouchesInView = false
        tableView.addGestureRecognizer(gesture)
        /// ends here...
    }
    
    @objc func hideKeyboard(_ gestureRecogniser: UIGestureRecognizer) {
        let point = gestureRecogniser.location(in: tableView)
        let indexPath = tableView.indexPathForRow(at: point)
        if indexPath != nil && indexPath!.section == 0 && indexPath!.row == 0 {
            return
        }
        descriptionTextView.resignFirstResponder()
    }

    /// done button closes screen
    @IBAction func done() {
        let hudView = HudView.hud(inView: navigationController!.view, animated: true)
        hudView.text = "Tagged"
        let delayedSeconds = 0.6
        /// 1
        let location = Location(context: managedObjectContext)
        /// 2
        location.category = categoryName
        location.date = date
        location.latitude = coordinates.latitude
        location.longitude = coordinates.longitude
        location.placemark = placeMark
        location.locationDescription = descriptionTextView.text
        /// 3
        do {
            try managedObjectContext.save()
            afterdelay(delayedSeconds) {
                hudView.hide(animated: true)
                self.navigationController?.popViewController(animated: true)
            }
        } catch {
            coreDataDidFailSaving(error)
        }
    }
    /// ends
    
    @IBAction func cancel() {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func categoryPickerdidPickCategory(_ segue: UIStoryboardSegue) {
        let controller = segue.source as! CategoryPickerVC
        categoryName = controller.selectedCategory
        categoryLabel.text = categoryName
    }
    
    /// update all labels
    func updateLocationLabel() {
        descriptionTextView.text = ""
        categoryLabel.text = categoryName
        latitudeLabel.text = String(format: "%.8f", coordinates.latitude)
        longitudeLabel.text = String(format: "%.8f", coordinates.longitude)
        if let placeMark = placeMark {
            addressLabel.text = string(from: placeMark)
        } else {
            addressLabel.text = "No Address Found"
        }
        ///dateLabel.text = format(date: Date())
    }
    
    //MARK:- Helper Method
    func string(from placeMark: CLPlacemark) -> String { // 1
           var line1 = ""
           // 2
           if let s = placeMark.subThoroughfare {
               line1 += s + " "
           }
           // 3
           if let s = placeMark.thoroughfare {
               line1 += s }
           // 4
           var line2 = ""
           if let s = placeMark.locality {
               line2 += s + " "
           }
           if let s = placeMark.administrativeArea {
               line2 += s + " "
           }
           if let s = placeMark.postalCode {
               line2 += s }
           // 5
           return line1 + "\n" + line2
       }
    
    func format(date: Date) -> String {
        return dateFormatter.string(from: date)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PickCategory" {
            let controller = segue.destination as! CategoryPickerVC
            controller.selectedCategory = categoryName
        }
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if indexPath.section == 0 || indexPath.section == 1 {
            return indexPath
        } else {
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 && indexPath.row == 0 {
            descriptionTextView.becomeFirstResponder()
        }
    }
}
