//
//  FirstViewController.swift
//  Location
//
//  Created by MARC on 4/5/20.
//  Copyright © 2020 MARC. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData

class CurrentLocationVC: UIViewController, CLLocationManagerDelegate {
    
    //MARK:- OUTLETS
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var tagButton: UIButton!
    @IBOutlet weak var getButton: UIButton!
    
    //MARK:- GEOCODING VARIABLE
    let geoCoder = CLGeocoder()
    var placeMark: CLPlacemark?
    var performReverseGeoCoding = false
    var lastGeoCodingError: Error?
    var managedObjectContext: NSManagedObjectContext!
    
    //MARK:- LOCATION MANAGER VARIABLE
    let LocationManager = CLLocationManager()
    var location: CLLocation?
    var updatingLocation = false
    var lastLocationError:  Error?

    override func viewDidLoad() {
        super.viewDidLoad()
        tagButton.isHidden = true
        updateLocationLabel()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isNavigationBarHidden = false
    }
    
    //MARK:- LocationMAnager delegate && Protocols here
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
        if (error as NSError).code == CLError.locationUnknown.rawValue {
            return
        }
        lastLocationError = error
        stopUpdaingLoaction()
        updateLocationLabel()
    }
    
    func stopUpdaingLoaction() {
        if updatingLocation {
            LocationManager.stopUpdatingLocation()
            LocationManager.delegate = nil
            updatingLocation = false
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let lastlocation = locations.last {
            if lastlocation.timestamp.timeIntervalSinceNow < -5 {
                return
            }
            if lastlocation.horizontalAccuracy < 0 {
                return
            }
            if location == nil || location!.horizontalAccuracy > lastlocation.horizontalAccuracy {
                lastLocationError = nil
                location = lastlocation
                if lastlocation.horizontalAccuracy <= LocationManager.desiredAccuracy {
                    print("*** we are done ***")
                    tagButton.isHidden = false
                    stopUpdaingLoaction()
                }
                updateLocationLabel()
                if !performReverseGeoCoding {
                    print("*** going to geocode ***")
                    performReverseGeoCoding = true
                    geoCoder.reverseGeocodeLocation(lastlocation) { (placeMark, error) in
                        self.lastGeoCodingError = error
                        if error == nil , let p = placeMark , !p.isEmpty {
                            self.placeMark = p.last!
                        } else {
                            self.placeMark = nil
                        }
                        self.performReverseGeoCoding = false
                        self.updateLocationLabel()
                    }
                }
            }
        }
    }
    
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
    
    func updateLocationLabel() {
        if let location = location {
            latitudeLabel.text = "Latitude: \(String(format: "%.8f", location.coordinate.latitude))"
            longitudeLabel.text = "Longitude: \(String(format: "%.8f", location.coordinate.longitude))"
            configureGetButton()
            if let placeMark = placeMark {
                addressLabel.text = string(from: placeMark)
            } else if performReverseGeoCoding {
                addressLabel.text = "Searching Address"
            } else if lastGeoCodingError != nil {
                addressLabel.text = "Error Finding Address"
            } else {
                addressLabel.text = "No Address Found"
            }
        }
        
        var errorMessage: String
        if let error = lastLocationError as NSError? {
            if error.domain == kCLErrorDomain && error.code == CLError.denied.rawValue {
                errorMessage = "Location Services Disabled"
            } else {
                errorMessage = "Error Getting Location"
            }
        } else if !CLLocationManager.locationServicesEnabled() {
            errorMessage = "Location Services Disabled"
        } else if updatingLocation {
            errorMessage = "Searching"
        } else {
            errorMessage = "Tap to get my location to start"
        }
        messageLabel.text = errorMessage
    }
    
    func startLocationManager() {
        LocationManager.delegate = self
        LocationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        LocationManager.startUpdatingLocation()
        updatingLocation = true
        updateLocationLabel()
    }
    
    
    //MARK:- ACTIONS
    @IBAction func getLocation() {
        getLocationApproval()
        if updatingLocation {
            stopUpdaingLoaction()
        } else {
            location = nil
            lastLocationError = nil
            placeMark = nil
            lastGeoCodingError = nil
            startLocationManager()
        }
    }
    
    func getLocationApproval() {
        let status = CLLocationManager.authorizationStatus()
        if status == .denied || status == .restricted {
            showLocationserviceDenied()
            return
        } else if status == .notDetermined {
            LocationManager.requestWhenInUseAuthorization()
            return
        }
    }
    
    func showLocationserviceDenied() {
        let alert = UIAlertController(title: "Location was denied", message: "loaction was denied by user. Please enable location for this app in settings", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    func configureGetButton() {
        if updatingLocation {
            getButton.setTitle("Stop", for: .normal)
        } else {
            getButton.setTitle("Get My location", for: .normal)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "TagLocation" {
            let controller = segue.destination as! LocationVC
            controller.coordinates = location!.coordinate
            controller.placeMark = placeMark
            controller.managedObjectContext = managedObjectContext
        }
    }


}

