//
//  MapViewController.swift
//  GoogleMapsxAllterco
//
//  Created by Veronika Hristozova on 7/13/17.
//  Copyright © 2017 Veronika Hristozova. All rights reserved.
//

import UIKit
import GoogleMaps

class MapViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var mapView: GMSMapView!
    
    // MARK: - Segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showSingleMarker" {
            if let marker = sender as? GMSMarker {
                if let markerToShow = RealmManager.shared.getObjectByID(id: "\(marker.position.latitude), \(marker.position.longitude)") {
                    let singleMapViewController = segue.destination as! SingleMarkerViewController
                    singleMapViewController.marker = markerToShow
                }
            }
        }
    }
    
    // MARK: - Alert Controller
    func showErrorAlert(with message: String) {
        let alertController = UIAlertController(title: message, message: "", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func setupUI() {
        mapView.clear()
        RealmManager.shared.getObjects()?.forEach({ marker in
            let position = CLLocationCoordinate2D(latitude: marker.lat, longitude: marker.long)
            let marker = GMSMarker(position: position)
            marker.map = mapView
        })
    }
    
    // MARK: - Lifecycle Control
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        
        //Removes the back button title on the navigationBar, just because I don't like it.
        self.navigationController?.navigationBar.topItem?.title?.removeAll()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupUI()
    }
}

// MARK: - GMSMapView Delegate
extension MapViewController: GMSMapViewDelegate {
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        //Drop the pin
        let marker = GMSMarker(position: coordinate)
        marker.map = mapView
        
        //Get data from the coordinate
        let geoCoder = GMSGeocoder()
        geoCoder.reverseGeocodeCoordinate(coordinate) { response, error in
            guard error == nil else { self.showErrorAlert(with: error?.localizedDescription ?? "Error"); return }
            
            if let address = response?.firstResult() {
                //Creates new marker
                let newMarker = Marker(id: "\(marker.position.latitude), \(marker.position.longitude)",
                                       locality: address.locality ?? "",
                                       lines: address.lines?.first ?? "",
                                       thoroughfare: address.thoroughfare ?? "" ,
                                       country: address.country ?? "",
                                       lat: address.coordinate.latitude,
                                       long: address.coordinate.longitude)
                
                //Saving to Realm
                RealmManager.shared.saveObject(newMarker, completion: nil)
            }
        }
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "showSingleMarker", sender: marker)
        }
        return true
    }
}
