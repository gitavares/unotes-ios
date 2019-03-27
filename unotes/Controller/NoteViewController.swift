//
//  NoteViewController.swift
//  unotes
//
//  Created by Giselle Tavares on 2019-03-18.
//  Copyright © 2019 Giselle Tavares. All rights reserved.
//

import UIKit
import MapKit
import RealmSwift

class NoteViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UIImagePickerControllerDelegate, UITextViewDelegate, UINavigationControllerDelegate {
    
    let realm = try! Realm()
    
    var selectedNote: Note?
    var selectedCategory = Category()
    var note: Note?
    var isNew = Bool()
    
    // for location
    var locationManager = CLLocationManager()
    var latitude: Double = 0
    var longitude: Double = 0
    
    // for image
    let pickerController = UIImagePickerController()
    
    @IBOutlet var txtNote: UITextView!
    @IBOutlet var txtTitle: UITextField!
    @IBOutlet var mapLocation: MKMapView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        txtNote.delegate = self
        pickerController.delegate = self
        pickerController.allowsEditing = true
        
//        let TapGesture = UITapGestureRecognizer(target: self, action: #selector(tapDetected(sender:)))
//        TapGesture.delegate = self as? UIGestureRecognizerDelegate
//        txtNote.addGestureRecognizer(TapGesture)
        
        loadTheNote()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        decodeTheNoteImageTags()
    }
    
    
    //MARK: - Buttons Action
    @IBAction func saveNote(_ sender: UIBarButtonItem) {
        if (txtTitle.text != "") {
            
            do {
                try realm.write {
                    if isNew {
                        let newNote = Note()
                        newNote.title = txtTitle.text!
                        newNote.note = txtNote.text ?? ""
                        newNote.modifiedDate = Date()
                        newNote.locationLatitude = String(latitude)
                        newNote.locationLongitude = String(longitude)
                        newNote.createdDate = Date()
                        isNew = false
                        selectedCategory.notes.append(newNote)
                        note = newNote
                    } else {
                        note?.title = txtTitle.text!
                        note?.note = txtNote.text ?? ""
                        note?.modifiedDate = Date()
                        //                note?.locationLatitude
                        //                note?.locationLongitude
                    }
                }
            } catch {
                print("Error saving the note: \(error)")
            }
            
        } else {
            let alertBox = UIAlertController(title: "The title can not be null", message: "", preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: "OK", style: .cancel) { (cancelAction) in return }
            
            alertBox.addAction(cancelAction)
            present(alertBox, animated: true, completion: nil)
        }
    }
    
    
    //MARK: - Load Note informations
    
    func loadTheNote(){
        
        note = selectedNote
        txtTitle.text = note?.title
        txtNote.text = note?.note
        
        if note?.locationLatitude != "" {
            // call the load map location function
            loadLocation()
        }
        
    }
    
    func updateTheNoteWithImageTag(named imageName: String, image: UIImage){
        //create and NSTextAttachment and add your image to it.
        var mutableAttributedString :NSMutableAttributedString!
        mutableAttributedString = NSMutableAttributedString(attributedString: txtNote.attributedText)
        
        let attachment = NSTextAttachment()
        attachment.image = image
        let imageInTags = imageName.setTagImage

        let attString = NSAttributedString(attachment: attachment)

        //add this attributed string to the current position.
        txtNote.textStorage.insert(attString, at: txtNote.selectedRange.location)
        let range = txtNote.selectedRange
        
        mutableAttributedString.beginEditing()
        mutableAttributedString.replaceCharacters(in: range, with: NSAttributedString(string: imageInTags))
        mutableAttributedString.endEditing()
        txtNote.attributedText = mutableAttributedString
        
    }
    
    func decodeTheNoteImageTags() {
        
        let attributedString = NSMutableAttributedString(string: txtNote.text)
        let range = NSRange(location: 0, length: attributedString.string.utf16.count)
        let regex = NSRegularExpression("\\[image\\](.*?)\\[/image\\]")
        
        for match in regex.matches(in: attributedString.string, options: [], range: range) {
            let imageRange = match.range
            
            if let rangeForImageName = Range(match.range(at: 1), in: attributedString.string){

                let imageName = String(attributedString.string[rangeForImageName])
                print("======imageName: \(imageName)")

                if let image = loadImage(named: imageName) {

                    let attachment = NSTextAttachment()
                    attachment.image = image
                    attachment.setImageWidth(width: txtNote.frame.size.width)
                    let attString = NSAttributedString(attachment: attachment)

                    //add this attributed string to the current position.
                    txtNote.textStorage.insert(attString, at: imageRange.location)

                } else {
                    print("Image not found")
                }
            }
            regex.stringByReplacingMatches(in: txtNote.text, options: [], range: imageRange, withTemplate: "")
        }
        
//        regex.stringByReplacingMatches(in: txtNote.text, options: [], range: range, withTemplate: "")
        
//        regex.replaceMatches(in: mutableString, options: [], range: range, withTemplate: "")
//        regex.stringByReplacingMatches(in: (txtNote?.text)!, options: [], range: range, withTemplate: "")
    }
    
    
    //MARK: - Gestures functions
    
//    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
//        return true
//    }
//
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        txtNote.resignFirstResponder()
//    }
//
//    @objc func tapDetected(sender: UITapGestureRecognizer) {
//
//        print("Tap On Image")
//        print("Tap Location",sender.location(in: sender.view))
//
//        guard case let senderView = sender.view, (senderView is UITextView) else {
//            return
//        }
//
//        // calculate layout manager touch location
//        let textView = senderView as! UITextView, // we sure this is an UITextView, so force casting it
//        layoutManager = textView.layoutManager
//
//        var location = sender.location(in: textView)
//        location.x -= textView.textContainerInset.left
//        location.y -= textView.textContainerInset.top
//
//        print("location", location)
//
//        let textContainer = textView.textContainer,
//        characterIndex = layoutManager.characterIndex(for: location, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil),
//        textStorage = textView.textStorage
//
//        guard characterIndex < textStorage.length else {
//            return
//        }
//    }
    
    //MARK: - Images functions
    
    @IBAction func addImage(_ sender: Any) {
        
        let alertController = UIAlertController(title: "Add an Image", message: "Choose From", preferredStyle: .actionSheet)
        
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { (action) in
            self.pickerController.sourceType = .camera
            self.present(self.pickerController, animated: true, completion: nil)
        }
        
        let photosLibraryAction = UIAlertAction(title: "Photos Library", style: .default) { (action) in
            self.pickerController.sourceType = .photoLibrary
            self.present(self.pickerController, animated: true, completion: nil)
        }
        
        let savedPhotosAction = UIAlertAction(title: "Saved Photos Album", style: .default) { (action) in
            self.pickerController.sourceType = .savedPhotosAlbum
            self.present(self.pickerController, animated: true, completion: nil)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        
        alertController.addAction(cameraAction)
        alertController.addAction(photosLibraryAction)
        alertController.addAction(savedPhotosAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
        present(pickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        guard let selectedImage = info[.originalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        
        let imageURL = info[UIImagePickerController.InfoKey.imageURL] as? URL
        let imageName = imageURL?.lastPathComponent
        
        //save the image
        saveImage(named: imageName!, image: selectedImage)
        
        //setting tag to the image range
        updateTheNoteWithImageTag(named: imageName!, image: selectedImage)
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func saveImage(named imageName: String, image: UIImage){
        
        let fileManager = FileManager.default
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileName = imageName
        let fileURL = documentsDirectory.appendingPathComponent("unotes/attachments/\(fileName)")
        
        if let data = image.jpegData(compressionQuality:  1.0),
            !fileManager.fileExists(atPath: fileURL.path) {
            do {
                do {
                    try fileManager.createDirectory(atPath: "unotes/attachments/",
                                                    withIntermediateDirectories: true,
                                                    attributes: nil)
                    print("Directory created: \(fileURL.path)")
                } catch {
                    print("Directory already exist: ", error.localizedDescription)
                }
                
                try data.write(to: fileURL)
                print("file saved")
                
            } catch {
                print("Image already exist: ", error)
                return
            }
        }
    
    }
    
    func loadImage(named imageName: String) -> UIImage? {
    
        let fileManager = FileManager.default
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileName = imageName
        let fileURL = documentsDirectory.appendingPathComponent("unotes/attachments/\(fileName)")
        
        if fileManager.fileExists(atPath: fileURL.path), let imageData: Data = try? Data(contentsOf: fileURL),
            let image: UIImage = UIImage(data: imageData, scale: UIScreen.main.scale) {
            return image
        } else {
            return nil
        }
        
    }
    


    //MARK: - Map location functions
    
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
        
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }

        if latitude == 0 {
            latitude = locValue.latitude
            longitude = locValue.longitude
        }
        
        let noteLocation = CLLocationCoordinate2DMake(latitude, longitude)
    
        let notePlacemark = MKPlacemark(coordinate: noteLocation, addressDictionary: nil)
        
        let noteAnnotation = MKPointAnnotation()
        
        if let location = notePlacemark.location {
            noteAnnotation.coordinate = location.coordinate
        }
        
        self.mapLocation.showAnnotations([noteAnnotation], animated: true)
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.red
        renderer.lineWidth = 5
        
        return renderer
    }
    
}

extension String {
    var setTagImage: String{
        return "[image]\(self)[/image]"
    }
}

extension NSRegularExpression {
    convenience init(_ pattern: String) {
        do {
            try self.init(pattern: pattern)
        } catch {
            preconditionFailure("Illegal regular expression: \(pattern).")
        }
    }
}

extension NSTextAttachment {
    func setImageWidth(width: CGFloat) {
        guard let image = image else { return }
        let ratio = image.size.height / image.size.width
        
        bounds = CGRect(x: bounds.origin.x, y: bounds.origin.y, width: width, height: ratio * width)
    }
}
