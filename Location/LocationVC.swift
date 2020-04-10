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
    @IBOutlet weak var addPhotoLbl: UILabel!
    @IBOutlet weak var photoImage: UIImageView!
    @IBOutlet weak var photoHeightConstraint: NSLayoutConstraint!
    var observer: Any?
    var image: UIImage? {
        didSet {
            photoImage.image = image
            photoImage.isHidden = false
            addPhotoLbl.text = ""
            photoHeightConstraint.constant = 260
            tableView.reloadData()
            photoImage.layer.cornerRadius = 7
            photoImage.layer.masksToBounds = true
        }
    }
    //MARK:- VARIABLES
    var coordinates = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    var placeMark: CLPlacemark?
    var categoryName = "No Category"
    var managedObjectContext: NSManagedObjectContext!
    var date = Date()
    var locationToEdit: Location? {
        didSet {
            if let location = locationToEdit {
                descriptionText = location.locationDescription
                categoryName = location.category
                date = location.date!
                coordinates = CLLocationCoordinate2DMake(location.latitude, location.longitude)
                placeMark = location.placemark
            }
        }
    }
    var descriptionText = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dismissPresentingViewController()
        if let location = locationToEdit {
            title = "Edit Location"
            if location.hasPhoto {
                if let theImage = location.photoImage {
                    image = theImage
                }
            }
        }
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
        let location: Location
        if let temp = locationToEdit {
            hudView.text = "Updated"
            location = temp
        } else {
            hudView.text = "Tagged"
            location = Location(context: managedObjectContext)
            location.photoID = nil
        }
        /// 2
        location.category = categoryName
        location.date = date
        location.latitude = coordinates.latitude
        location.longitude = coordinates.longitude
        location.placemark = placeMark
        location.locationDescription = descriptionTextView.text
        
        /// save image
        if let image = image {
            if !location.hasPhoto {
                location.photoID = Location.nextPossibleID() as NSNumber
            }
            if let data = image.jpegData(compressionQuality: 0.5) {
                do {
                    try data.write(to: location.photoURL, options: .atomic)
                } catch {
                    print("error******\(error.localizedDescription)")
                }
            }
        }
        
        /// 3
        let delayedSeconds = 0.6
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
        descriptionTextView.text = descriptionText
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
        } else if indexPath.section == 1 && indexPath.row == 0 {
            tableView.deselectRow(at: indexPath, animated: true)
            showPhotoMenu()
        }
    }
    
    /// this function dismiss all presenting viewController
    func dismissPresentingViewController() {
        observer = NotificationCenter.default.addObserver(forName: UIApplication.didEnterBackgroundNotification, object: nil, queue: OperationQueue.main) { [weak self] _ in
            if let weakSelf = self {
                if weakSelf.presentedViewController != nil {
                    weakSelf.dismiss(animated: true, completion: nil)
                }
                weakSelf.descriptionTextView.resignFirstResponder()
            }
        }
    }
}

extension LocationVC: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    /// this function is to take picture with camera
    func takePictureFromCamera() {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .camera
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
        
    }
    
    func showPhoto() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            showPhotoMenu()
        } else {
            choosePhotosFromLibrary()
        }
    }
    
    /// this enables you to choose photos from library
    func choosePhotosFromLibrary() {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }
    
    func showPhotoMenu() {
        let photoAlert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "CANCEL", style: .cancel, handler: nil)
        photoAlert.addAction(cancelAction)
        let takePhoto = UIAlertAction(title: "Take Photo", style: .default, handler: { _ in
            self.takePictureFromCamera()
        })
        photoAlert.addAction(takePhoto)
        let fromLibrary = UIAlertAction(title: "Choose From Photo Library", style: .default, handler: { _ in
            self.choosePhotosFromLibrary()
        })
        photoAlert.addAction(fromLibrary)
        present(photoAlert, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
}
