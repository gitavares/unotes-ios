//
//  NoteViewController.swift
//  unotes
//
//  Created by Giselle Tavares on 2019-03-18.
//  Copyright © 2019 Giselle Tavares. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class NoteTableViewController: DefaultTableViewController, UISearchBarDelegate {
    
    let realm = try! Realm()
    var notes: Results<Note>?
    var selectedCategory: Category? {
        didSet {
            loadAllNotesByCategory()
        }
    }
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var searchResult = [Note]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.delegate = self
        
        searchBar.showsCancelButton = true
        for subView1 in searchBar.subviews{
            for subView2 in subView1.subviews{
                if subView2.isKind(of: UIButton.self){
                    let customizedCancelButton:UIButton = subView2 as! UIButton
                    customizedCancelButton.isEnabled = true
                    customizedCancelButton.setTitle("", for: UIControl.State.normal)
                    let imageButton = UIImage(named: "sort")
//                    let imageButton = UIImage(image: UIImage(named: "sort"), scaledTo: CGSize(width: 20, height: 30))
                    customizedCancelButton.setBackgroundImage(imageButton, for: UIControl.State.normal)
                }
            }
        }
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        title = selectedCategory?.name ?? "Notes"
        loadAllNotesByCategory()

    }
    

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let note = notes?[indexPath.row] {
            cell.textLabel?.text = note.title
            cell.detailTextLabel?.text = "\(dateFormatTime(date: note.createdDate ?? Date()))  \(note.note ?? "")"
            if note.lastImage != "" {
                cell.imageView?.image = UIImage(named: note.lastImage ?? "")
            }
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToNote", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let note = segue.destination as? NoteViewController {
            if segue.identifier == "goToNote" {
                if let indexPath = self.tableView.indexPathForSelectedRow {
                    note.selectedNote = notes?[indexPath.row]
                    note.selectedCategory = selectedCategory!
                    note.isNew = false
                }
            } else if segue.identifier == "addNote" {
                note.isNew = true
                note.selectedCategory = selectedCategory!
            }
        }
        
    }
    
    //MARK: Button actions
    
    @IBAction func addNote(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "addNote", sender: self)
    }
    
    //MARK: - Notes CRUD
    
    func loadAllNotesByCategory() {
        notes = selectedCategory?.notes.sorted(byKeyPath: "createdDate", ascending: false)
        tableView.reloadData()
    }
    
    override func delete(at indexPath: IndexPath) {
        if let note = notes?[indexPath.row] {
            
            let alertBox = UIAlertController(title: "Delete Note", message: "Are you sure? \n\nNote Title:\n \(note.title)", preferredStyle: .alert)
            
            let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (action) in
                
                do {
                    try self.realm.write {
                        // show a alert with the count of all notes associated
                        self.realm.delete(note)
                        // delete also the notes associated or let the user choose between delete all or transfer for to another default category
                        self.loadAllNotesByCategory()
                    }
                } catch {
                    print("Error deleting note: \(error)")
                }
                
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (cancelAction) in
                return
            }
            
            alertBox.addAction(deleteAction)
            alertBox.addAction(cancelAction)
            
            present(alertBox, animated: true, completion: nil)
        }
    }
    
    //MARK: - Utils
    
    func dateFormatTime(date : Date) -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_CA")
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        
//        dateFormatter.dateStyle = .short
//        dateFormatter.timeStyle = .none
        
        return dateFormatter.string(from: date)
    }
    
    //MARK: - Search Bar
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        notes = notes?.filter("title CONTAINS[cd] %@ OR note CONTAINS[cd] %@", searchBar.text!, searchBar.text!).sorted(byKeyPath: "title", ascending: true)
        
        tableView.reloadData()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchBar.showsBookmarkButton = true
        
        if searchBar.text?.count == 0 {
            loadAllNotesByCategory()

            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        let alertController = UIAlertController(title: "Order By", message: "", preferredStyle: .actionSheet)
        
        let byTitleAsc = UIAlertAction(title: "Title A-Z", style: .default) { (action) in
            
            self.notes = self.notes?.sorted(byKeyPath: "title", ascending: true)
            self.tableView.reloadData()
        }
        
        let byTitleDesc = UIAlertAction(title: "Title Z-A", style: .default) { (action) in
            
            self.notes = self.notes?.sorted(byKeyPath: "title", ascending: false)
            self.tableView.reloadData()
        }
        
        let byDateAsc = UIAlertAction(title: "Created Date Newest", style: .default) { (action) in
            self.notes = self.notes?.sorted(byKeyPath: "createdDate", ascending: false)
            self.tableView.reloadData()
        }
        
        let byDateDesc = UIAlertAction(title: "Created Date Oldest", style: .default) { (action) in
            self.notes = self.notes?.sorted(byKeyPath: "createdDate", ascending: true)
            self.tableView.reloadData()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        
        alertController.addAction(byTitleAsc)
        alertController.addAction(byTitleDesc)
        alertController.addAction(byDateAsc)
        alertController.addAction(byDateDesc)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
}
