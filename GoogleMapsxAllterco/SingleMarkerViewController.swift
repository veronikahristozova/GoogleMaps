//
//  SingleMarkerViewController.swift
//  GoogleMapsxAllterco
//
//  Created by Veronika Hristozova on 7/13/17.
//  Copyright © 2017 Veronika Hristozova. All rights reserved.
//

import UIKit

enum JPEGQuality: CGFloat {
    case lowest  = 0
    case low     = 0.25
    case medium  = 0.5
    case high    = 0.75
    case highest = 1
}

class SingleMarkerViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var addressLinesLabel: UILabel!
    @IBOutlet weak var addressThoroughfareLabel: UILabel!
    @IBOutlet weak var localityLabel: UILabel!
    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var markerImageView: UIImageView!
    
    // MARK: - Variables
    var marker: Marker?
    lazy var imagePickerController = UIImagePickerController()

    // MARK: - IBActions
    @IBAction func didTapDeleteMarkerButton(_ sender: UIBarButtonItem) {
        //Presenting Alert
        let alertController = UIAlertController(title: "Delete this marker?", message: "", preferredStyle: .alert)
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
            guard let markerID = self.marker?.id else { return }
            RealmManager.shared.deleteObjectByID(id: markerID, completion: { success in
                if success {
                    self.navigationController?.popViewController(animated: true)
                }
            })
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        
        alertController.addAction(cancelAction)
        alertController.addAction(deleteAction)
        present(alertController, animated: true, completion: nil)
        
    }
    // MARK: - Setup UI
    func setupUI() {
        if let marker = marker {
            addressLinesLabel.text = marker.lines
            addressThoroughfareLabel.text = marker.thoroughfare
            localityLabel.text = marker.locality
            countryLabel.text = marker.country
            markerImageView.image = UIImage(data: marker.imageData as Data)
        }
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SingleMarkerViewController.handleImageViewTap))
        markerImageView.addGestureRecognizer(gestureRecognizer)
    }
    
    func setupImagePickerController() {
        imagePickerController.delegate = self
    }
    
    func handleImageViewTap() {
        let alert = UIAlertController(title: "", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
            self.openCamera()
        }))
        
        alert.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { _ in
            self.openPhotoLibrary()
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func openCamera() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePickerController.sourceType = .camera
            imagePickerController.allowsEditing = true
            self.present(imagePickerController, animated: true, completion: nil)
        } else {
            let alert  = UIAlertController(title: "Warning", message: "Camera missing", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func openPhotoLibrary() {
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.allowsEditing = true
        self.present(imagePickerController, animated: true, completion: nil)
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupImagePickerController()
    }
}

// MARK: - UIImagePickerController Delegate
extension SingleMarkerViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            markerImageView.image = image
            //Update the Marker with its new image
            if let marker = marker {
                //Compress the image quality because Realm supports upto 16MB
                if let representationData = UIImageJPEGRepresentation(image, JPEGQuality.medium.rawValue) {
                    let data = NSData(data: representationData)
                    let newMarker = Marker(id: marker.id,
                                           locality: marker.locality,
                                           lines: marker.lines,
                                           thoroughfare: marker.thoroughfare,
                                           country: marker.country,
                                           lat: marker.lat,
                                           long: marker.long,
                                           imageData: data)
                    
                    
                    RealmManager.shared.saveObject(newMarker, completion: { success in
                        if success {
                            self.dismiss(animated: true, completion: nil)
                        }
                    })
                }
            }
        } else {
            print("Coult not cast media to UIImage ")
        }
    }
}
