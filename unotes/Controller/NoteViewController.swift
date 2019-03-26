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
        
//        loadFormattedTextView()
        
        if note?.locationLatitude != "" {
            // call the load map location function
            loadLocation()
        }
        
    }
    
//    func loadFormattedTextView(){
//        let attrs = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .body)]
//        let attrString = NSAttributedString(string: note?.note! ?? "", attributes: attrs)
//        textStorage = FormatTextStorage()
//        textStorage.append(attrString)
//
//        txtNote.delegate = self
//        view.addSubview(txtNote)
//    }
    
    func updateTheNoteWithImageTag(named imageName: String, image: UIImage){
        //create and NSTextAttachment and add your image to it.
        var mutableAttributedString :NSMutableAttributedString!
        mutableAttributedString = NSMutableAttributedString(attributedString: txtNote.attributedText)
        
        let attachment = NSTextAttachment()
        attachment.image = image
//        let oldWidth = attachment.image!.size.width;
//        let scaleFactor = (oldWidth / (txtNote.frame.size.width - 10))
//
//        attachment.image = UIImage(cgImage: attachment.image!.cgImage!, scale: scaleFactor, orientation: .up)
        let imageInTags = imageName.setTagImage
        //put your NSTextAttachment into and attributedString
        let attString = NSAttributedString(attachment: attachment)
        //add this attributed string to the current position.
        txtNote.textStorage.insert(attString, at: txtNote.selectedRange.location)
        let range = txtNote.selectedRange
        
        mutableAttributedString.beginEditing()
        mutableAttributedString.replaceCharacters(in: range, with: NSAttributedString(string: imageInTags))
        mutableAttributedString.endEditing()
        txtNote.attributedText = mutableAttributedString
        
//        print("======attString: \(attString)")
//        print("======txtNote.attributedText: \(String(describing: txtNote.attributedText))")
//        print("======txtNote.textStorage: \(txtNote.textStorage)")
//        print("======txtNote: \(String(describing: txtNote))")
//        print("======txtNote TEXT: \(String(describing: txtNote.text))")
        
//        print("\(txtNote.selectedRange.location)")
//
//        print("===Attribute text: \(String(describing: txtNote.attributedText))")
//        print("===Only txtNote: \(String(describing: txtNote))")
    }
    
    func decodeTheNoteImageTags() {
        
        let attributedString = NSMutableAttributedString(string: txtNote.text)
        print("=====attributedString: \(attributedString)")
        
        let range = NSRange(location: 0, length: attributedString.string.utf16.count)
        let regex = NSRegularExpression("\\[image\\](.*?)\\[/image\\]")
        
        for match in regex.matches(in: attributedString.string, options: [], range: range) {
            if let rangeForImageName = Range(match.range(at: 1), in: attributedString.string){
                
                let imageName = String(attributedString.string[rangeForImageName])
                print("======imageName: \(imageName)")
                
//                let imageNameRange = NSRange(imageName)
                
                if let image = loadImage(named: imageName) {
                    
//                    let textAttachment = NSTextAttachment()
//                    textAttachment.image = UIImage(named: "Image")
//                    textAttachment.setImageHeight(16) // Whatever you need to match your font
//
//                    let imageString = NSAttributedString(attachment: textAttachment)
//                    yourAttributedString.appendAttributedString(imageString)
                    
                    
                  
                    let attachment = NSTextAttachment()
                    attachment.image = image
                    attachment.setImageHeight(width: txtNote.frame.size.width)
//                    let oldWidth = attachment.image!.size.width
//                    let scaleFactor = (oldWidth / (txtNote.frame.size.width - 10))
//                    attachment.image = UIImage(cgImage: attachment.image!.cgImage!, scale: scaleFactor, orientation: .up)
                    
                    let attString = NSAttributedString(attachment: attachment)
                    
//                    attributedString.beginEditing()
//                    attributedString.replaceCharacters(in: imageNameRange!, with: attString)
//                    attributedString.endEditing()
                    
                    //add this attributed string to the current position.
                    txtNote.textStorage.insert(attString, at: txtNote.selectedRange.location)
                } else {
                    print("Image not found")
                }
            }
        }
        
//        let matchesCount = regex.numberOfMatches(in: attributedString.string, options: [], range: range)
//        print("======matchesCount: \(matchesCount)")
//
//        for _ in 0..<matchesCount {
////                let match = regex.matches(in: attributedString.string, options: [], range: NSRange(location: 0, length: attributedString.string.utf16.count))[0]
//            let match = regex.matches(in: attributedString.string, options: [], range: range)[0]
//            print("======match: \(match)")
//
////                if let rangeForImageName = Range(match.range(at: 1), in: attributedString.string){
//
//            }
//        }
        
            
        
        
        
//        let attachment = NSTextAttachment()
//        attachment.image = loadImage(named: imageName)
//        let oldWidth = attachment.image!.size.width;
//        let scaleFactor = (oldWidth / (txtNote.frame.size.width - 10))
//
//        attachment.image = UIImage(cgImage: attachment.image!.cgImage!, scale: scaleFactor, orientation: .up)
//        //put your NSTextAttachment into and attributedString
//        let attString = NSAttributedString(attachment: attachment)
//        //add this attributed string to the current position.
//        txtNote.textStorage.insert(attString, at: txtNote.selectedRange.location)
        
//        return attributedString
        
        
//        let attributedString = NSMutableAttributedString(string: self, attributes: nil)
//        do {
//            let regex = try NSRegularExpression(pattern: "<img>(.*?)</img>", options: [])
//            let matchesCount = regex.matches(in: attributedString.string,
//                                             options: [],
//                                             range: NSRange(location: 0, length: attributedString.string.utf16.count)).count
//            for _ in 0..<matchesCount {
//                let match = regex.matches(in: attributedString.string,
//                                          options: [],
//                                          range: NSRange(location: 0, length: attributedString.string.utf16.count))[0]
//                if let rangeForURL = Range(match.range(at: 1), in: attributedString.string) {
//                    let imageLocalURL = String(attributedString.string[rangeForURL])
//
//                    let lowerBoundForImageLocalURLwrappedInTags = self.distance(from: self.startIndex, to: rangeForURL.lowerBound) - 5
//                    let upperBoundForImageLocalURLwrappedInTags = self.distance(from: self.startIndex, to: rangeForURL.upperBound) + 6
//                    if let localImage = UIImage.loadImageFrom(path: imageLocalURL)
//                    {
//                        let imageAttachment = NSTextAttachment()
//                        let oldWidth = localImage.size.width
//                        imageAttachment.image = localImage.resizeImage(scale: (UIScreen.main.bounds.width - 10)/oldWidth)
//                        let imageString = NSMutableAttributedString(attachment: imageAttachment)
//                        let rangeForImageLocalURLwrappedInTags = NSMakeRange(lowerBoundForImageLocalURLwrappedInTags, upperBoundForImageLocalURLwrappedInTags - lowerBoundForImageLocalURLwrappedInTags)
//                        attributedString.beginEditing()
//                        attributedString.replaceCharacters(in: rangeForImageLocalURLwrappedInTags,
//                                                           with: imageString)
//                        attributedString.endEditing()
//                    }
//                }
//            }
//        } catch(let error) {
//            print(error.localizedDescription)
//        }
//        return attributedString
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

        // The info dictionary may contain multiple representations of the image. You want to use the original.
        guard let selectedImage = info[.originalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        
        let imageURL = info[UIImagePickerController.InfoKey.imageURL] as? URL
        print("=====Image URL: \(String(describing: imageURL))")
        
        let imageName = imageURL?.lastPathComponent
        print("=====Image NAME: \(String(describing: imageName))")

        print("Image------:\(selectedImage)")
        
        //save the image
        saveImage(named: imageName!, image: selectedImage)
        updateTheNoteWithImageTag(named: imageName!, image: selectedImage)
        
        //create and NSTextAttachment and add your image to it.
//        let attachment = NSTextAttachment()
//        attachment.image = selectedImage
//        let oldWidth = attachment.image!.size.width;
//        let scaleFactor = (oldWidth / (txtNote.frame.size.width - 10))
//
//        attachment.image = UIImage(cgImage: attachment.image!.cgImage!, scale: scaleFactor, orientation: .up)
//        //put your NSTextAttachment into and attributedString
//        let attString = NSAttributedString(attachment: attachment)
//        //add this attributed string to the current position.
//        txtNote.textStorage.insert(attString, at: txtNote.selectedRange.location)
//
//        print("\(txtNote.selectedRange.location)")
        
        
        
        
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
        
//        print("===Attribute text: \(String(describing: txtNote.attributedText))")
//        print("===Only txtNote: \(String(describing: txtNote))")
//
//        // Dismiss the picker.
        dismiss(animated: true, completion: nil)
        
        
        // save the image with the same name and in the same folder. Use a kind of tag to be replaced when fetch the note again
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
        
        print("======File PATH: \(fileURL.path)")
    }
    
    func loadImage(named imageName: String) -> UIImage? {
    
        let fileManager = FileManager.default
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileName = imageName
        let fileURL = documentsDirectory.appendingPathComponent("unotes/attachments/\(fileName)")
        
        if fileManager.fileExists(atPath: fileURL.path), let imageData: Data = try? Data(contentsOf: fileURL),
            let image: UIImage = UIImage(data: imageData, scale: UIScreen.main.scale) {
            print("====Image loaded! \(image)")
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
    func setImageHeight(width: CGFloat) {
        guard let image = image else { return }
        let ratio = image.size.height / image.size.width
        
        bounds = CGRect(x: bounds.origin.x, y: bounds.origin.y, width: width, height: ratio * width)
    }
}
