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
    @IBOutlet weak var imgView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let selection = UIView(frame: CGRect.zero)
        selection.backgroundColor = UIColor(white: 1.0, alpha: 0.3)
        selectedBackgroundView = selection
        
        imgView.layer.cornerRadius = imgView.bounds.size.width / 2
        imgView.clipsToBounds = true
        separatorInset = UIEdgeInsets(top: 0, left: 82, bottom: 0,
        right: 0)
    }

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
        imageView?.image = thumbnail(for: location)
    }
    
    func thumbnail(for locations: Location) -> UIImage {
        if locations.hasPhoto, let image = locations.photoImage {
            return image.resize(withBounds: CGSize(width: 52, height: 52))
        }
        return UIImage(named: "No Photo")!
    }
}
