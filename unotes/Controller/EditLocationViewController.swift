//
//  EditLocationViewController.swift
//  unotes
//
//  Created by Giselle Tavares on 2019-03-27.
//  Copyright © 2019 Giselle Tavares. All rights reserved.
//

import UIKit
import MapKit
import RealmSwift

class EditLocationViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var mapLocation: MKMapView!
    
    let realm = try! Realm()
    
    var selectedNote: Note?
    var selectedCategory = Category()
    var note: Note?
    
    // for location
    var locationManager = CLLocationManager()
    var latitude: Double = 0
    var longitude: Double = 0
    var locationPin: MKPointAnnotation?
    var newLocationPin: MKPointAnnotation?
    var newLatitude: Double = 0
    var newLongitude: Double = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapLocation.delegate = self
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(mapTapped))
        mapLocation.addGestureRecognizer(tapGesture)
        
        loadLocation()
    }
    
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        if isMovingFromParent {
//            if let viewControllers = self.navigationController?.viewControllers {
//                if (viewControllers.count >= 1) {
//                    let previousViewController = viewControllers[viewControllers.count-1] as! NoteViewController
//                    // whatever you want to do
//
//                    previousViewController.viewDidLoad()
////                    performSegue(withIdentifier: "goToNoteBack", sender: self)
//                }
//            }
//        }
//    }
    
//    override func didMove(toParent parent: UIViewController?) {
//        super.didMove(toParent: parent)
//
//        if parent == nil {
//            debugPrint("Back Button pressed.")
//            performSegue(withIdentifier: "goToNoteBack", sender: self)
//        }
//    }
//
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//
//        if let note = segue.destination as? NoteViewController {
//            note.selectedNote = selectedNote
//            note.selectedCategory = selectedCategory
//            note.isNew = false
//        }
//
//    }
    
    //MARK: - Map functions
    
    @objc func mapTapped(gestureRecognizer: UIGestureRecognizer){
        let touchPoint = gestureRecognizer.location(in: mapLocation)
        let coordinates = mapLocation.convert(touchPoint, toCoordinateFrom: mapLocation)
        
        //clean the previous pin
        let allAnnotations = self.mapLocation.annotations
        self.mapLocation.removeAnnotations(allAnnotations)
        
        //mark a new pin
        newLocationPin = MKPointAnnotation()
        newLocationPin?.coordinate = coordinates
        getAddress(from: coordinates) { address in
            if let address = address {
                self.newLocationPin?.title = address
                self.mapLocation.addAnnotation(self.newLocationPin!)
            } else {
                self.mapLocation.addAnnotation(self.newLocationPin!)
            }
            
            let newLocation = CLLocation(latitude: (self.newLocationPin?.coordinate.latitude)!, longitude: (self.newLocationPin?.coordinate.longitude)!)
            self.newLatitude = newLocation.coordinate.latitude
            self.newLongitude = newLocation.coordinate.longitude
        }
    }
    
    
    func getAddress(from coordinates: CLLocationCoordinate2D, completion: @escaping (String?) -> ()) {
        let geoCoder = CLGeocoder()
        let location = CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)
        geoCoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) -> Void in
            if let error = error {
                print(error.localizedDescription)
                completion(nil)
            }
            
            var placeMark: CLPlacemark!
            placeMark = placemarks?[0]
            
            guard let country = placeMark.country else {
                completion(nil)
                return
            }
            guard let city = placeMark.subAdministrativeArea else {
                completion(country)
                return
            }
            guard let street = placeMark.thoroughfare else {
                completion("\(city), \(country)")
                return
            }
            completion("\(street), \(city), \(country)")
        })
    }
    
    func loadLocation() {
        
        if let savedLatitude = note?.locationLatitude {
            latitude = Double(savedLatitude) ?? 0
        }
        
        if let savedLongitude = note?.locationLongitude  {
            longitude = Double(savedLongitude) ?? 0
        }
        
        mapLocation.delegate = self
        
        // To get authorization to get the current location
        if CLLocationManager.locationServicesEnabled() {
            self.locationManager.requestWhenInUseAuthorization()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
        
        //Zoom to user location
        if let userLocation = locationManager.location?.coordinate {
            let viewRegion = MKCoordinateRegion(center: userLocation, latitudinalMeters: 200, longitudinalMeters: 200)
            mapLocation.setRegion(viewRegion, animated: false)
        }
        
        DispatchQueue.main.async {
            self.locationManager.startUpdatingLocation()
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let noteLocation = CLLocationCoordinate2DMake(latitude, longitude)
        
        let notePlacemark = MKPlacemark(coordinate: noteLocation, addressDictionary: nil)
        
        let noteAnnotation = MKPointAnnotation()
        
        if let location = notePlacemark.location {
            noteAnnotation.coordinate = location.coordinate
            getAddress(from: noteLocation) { (address) in
                noteAnnotation.title = address
                self.mapLocation.addAnnotation(noteAnnotation)
            }
        }
        
        self.mapLocation.showAnnotations([noteAnnotation], animated: true)
        
    }
    
//    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
//        if annotation is MKUserLocation {
//            return nil
//
//        } else {
//
//            if let _ = Double(String(annotation.title!!.split(separator: " ")[0])) {
//                let annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "some")
//                let annotationLabel = UILabel(frame: CGRect(x: -52, y: 5, width: 105, height: 30))
//                annotationLabel.numberOfLines = 0
//                annotationLabel.textAlignment = .center
//                annotationLabel.font = UIFont(name: "Rockwell", size: 10)
//                annotationLabel.text = annotation.title!
//                annotationView.image = nil
//                annotationView.addSubview(annotationLabel)
//                return annotationView
//            } else {
//                return nil
//            }
//
//        }
//    }
    
    //MARK: - Buttons Actions
    
    @IBAction func saveLocation(_ sender: UIBarButtonItem) {
        if newLatitude != 0 && newLatitude != latitude {
            do {
                try realm.write {
                    note?.modifiedDate = Date()
                    note?.locationLatitude = String(newLatitude)
                    note?.locationLongitude = String(newLongitude)
                }
            } catch {
                print("Error saving the new location: \(error)")
            }
        }
    }
    

}
