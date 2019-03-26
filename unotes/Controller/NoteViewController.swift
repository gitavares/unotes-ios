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
        
        let TapGesture = UITapGestureRecognizer(target: self, action: #selector(tapDetected(sender:)))
        TapGesture.delegate = self as? UIGestureRecognizerDelegate
        txtNote.addGestureRecognizer(TapGesture)
        
        loadTheNote()
        
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
                        //                note?.location
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
    
    
    //MARK: - Gestures functions
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        txtNote.resignFirstResponder()
    }

    @objc func tapDetected(sender: UITapGestureRecognizer) {

        print("Tap On Image")
        print("Tap Location",sender.location(in: sender.view))

        guard case let senderView = sender.view, (senderView is UITextView) else {
            return
        }

        // calculate layout manager touch location
        let textView = senderView as! UITextView, // we sure this is an UITextView, so force casting it
        layoutManager = textView.layoutManager

        var location = sender.location(in: textView)
        location.x -= textView.textContainerInset.left
        location.y -= textView.textContainerInset.top

        print("location", location)

        let textContainer = textView.textContainer,
        characterIndex = layoutManager.characterIndex(for: location, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil),
        textStorage = textView.textStorage

        guard characterIndex < textStorage.length else {
            return
        }
    }
    
    //MASK: - Images functions
    
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

        // The info dictionary may contain multiple representations of the image. You want to use the original.
        guard let selectedImage = info[.originalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        
        let imageURL = info[UIImagePickerController.InfoKey.imageURL] as? URL
        
        print("=====Image URL: \(String(describing: imageURL))")
        
        //this block of code grabs the path of the file
        let imagePath =  imageURL?.path
        print("=====Image PATH: \(String(describing: imagePath))")
        
        let localPath = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(imagePath!)
        print("=====Image LOCAL PATH: \(String(describing: localPath))")
        
        //this block of code adds data to the above path
        let path = localPath?.relativePath
        print("=====JUST PATH: \(String(describing: localPath))")
        
        let imageName = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        print("=====Image NAME: \(String(describing: imageName))")
        
        let data = imageName.pngData()
        print("=====Image DATA: \(String(describing: data))")
        
//        data?.writeToFile(imagePath, atomically: true)
        
        //this block grabs the NSURL so you can use it in CKASSET
        let photoURL = NSURL(fileURLWithPath: path!)
        print("=====Image URL in the end: \(String(describing: photoURL))")
        
//        guard let theImage = NSImage(contentsOfURL: openPanel.URL!) else {
//            showErrorMessage("Unable to load image")
//            return
//        }
//        guard let store = self.textEditor.textStorage else { abort() }
//
//        let cell = NSTextAttachmentCell(imageCell: theImage)
//        let txtAtt = NSTextAttachment(data: theImage.imageJPGRepresentation, ofType: kUTTypeJPEG as String)
//        txtAtt.attachmentCell = cell
//        let str = NSAttributedString(attachment: txtAtt)
//        let range = self.textEditor.selectedRange()
//        store.replaceCharactersInRange(range, withAttributedString: str)

        print("Image------:\(selectedImage)")
    
        
        //create and NSTextAttachment and add your image to it.
        let attachment = NSTextAttachment()
        attachment.image = selectedImage
        let oldWidth = attachment.image!.size.width;
        let scaleFactor = (oldWidth / (txtNote.frame.size.width - 10))
        
        attachment.image = UIImage(cgImage: attachment.image!.cgImage!, scale: scaleFactor, orientation: .up)
        //put your NSTextAttachment into and attributedString
        let attString = NSAttributedString(attachment: attachment)
        //add this attributed string to the current position.
        txtNote.textStorage.insert(attString, at: txtNote.selectedRange.location)
        
//        var attributedString :NSMutableAttributedString!
//        attributedString = NSMutableAttributedString(attributedString: txtNote.attributedText)
//        let textAttachment = NSTextAttachment()
//        textAttachment.image = selectedImage
//
//        let oldWidth = textAttachment.image!.size.width;
//        let scaleFactor = (oldWidth / (txtNote.frame.size.width - 10))
//
//        textAttachment.image = UIImage(cgImage: textAttachment.image!.cgImage!, scale: scaleFactor, orientation: .up)
//
//        let attrStringWithImage = NSAttributedString(attachment: textAttachment)
//        attributedString.append(attrStringWithImage)
//        txtNote.attributedText = attributedString
        
        print("===Attribute text: \(txtNote.attributedText)")
        print("===Only txtNote: \(txtNote)")
//
//        // Dismiss the picker.
        dismiss(animated: true, completion: nil)
        
        
        // save the image with the same name and in the same folder. Use a kind of tag to be replaced when fetch the note again
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    
    func saveImage(){
        
    }
    
    func loadImages(){
        
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

extension UITextView {
    
    func replaceTags(notes: String) {
        
    }
    
    
    func getParts() -> [AnyObject] {
        var parts = [AnyObject]()
        
        let attributedString = self.attributedText
        let range = self.selectedRange//NSMakeRange(0, (attributedString?.length)!)
        attributedString?.enumerateAttributes(in: range, options: NSAttributedString.EnumerationOptions(rawValue: 0)) { (object, range, stop) in
            if object.keys.contains(NSAttributedString.Key.attachment) {
                if let attachment = object[NSAttributedString.Key.attachment] as? NSTextAttachment {
                    if let image = attachment.image {
                        parts.append(image)
                    } else if let image = attachment.image(forBounds: attachment.bounds, textContainer: nil, characterIndex: range.location) {
                        parts.append(image)
                    }
                }
            } else {
                let stringValue : String = attributedString!.attributedSubstring(from: range).string
                if (!stringValue.trimmingCharacters(in: .whitespaces).isEmpty) {
                    parts.append(stringValue as AnyObject)
                }
            }
        }
        return parts
    }
}

//extension NSAttributedString.Key {
//    static let imagePath = NSAttributedString.Key(rawValue: "imagePath")
//}

//extension NSImage {
//    var imagePNGRepresentation: NSData {
//        return NSBitmapImageRep(data: TIFFRepresentation!)!.representationUsingType(.NSPNGFileType, properties: [:])!
//    }
//    var imageJPGRepresentation: NSData {
//        return NSBitmapImageRep(data: TIFFRepresentation!)!.representationUsingType(.NSJPEGFileType, properties: [:])!
//    }
//}
