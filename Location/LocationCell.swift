//
//  LocationCell.swift
//  Location
//
//  Created by MARC on 4/7/20.
//  Copyright © 2020 MARC. All rights reserved.
//

import UIKit

class LocationCell: UITableViewCell {

    @IBOutlet weak var descriptionLbl: UILabel!
    @IBOutlet weak var addressLbl: UILabel!

    // MARK:- Helper Method
    func configure(for location: Location) {
        if location.locationDescription.isEmpty {
            descriptionLbl.text = "(No Description)"
        } else {
            descriptionLbl.text = location.locationDescription
        }
        if let placemark = location.placemark {
            var text = ""
            if let s = placemark.subThoroughfare {
                text += s + " "
            }
            if let s = placemark.thoroughfare {
                text += s + ", "
            }
            if let s = placemark.locality {
                text += s
            }
            addressLbl.text = text
        } else {
            addressLbl.text = String(format: "Lat: %.8f, Long: %.8f", location.latitude, location.longitude)
        }
    }
}
