//
//  ViewController.swift
//  uwrite
//
//  Created by Giselle Tavares on 2019-03-16.
//  Copyright © 2019 Giselle Tavares. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class CategoryTableViewController: DefaultTableViewController {
    
    let realm = try! Realm()
    
    var categories: Results<Category>?

    override func viewDidLoad() {
        super.viewDidLoad()
        loadAllCategories()
        
        let documentDirectoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
        print("=====App DIR: \(String(describing: documentDirectoryPath))")
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?.count ?? 1
    }
    
    
     override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let category = categories?[indexPath.row] {
            cell.textLabel?.text = "\(category.name) (\(category.notes.count))"
            //            guard let color = UIColor(hexString: category.color) else { fatalError("Error setting the category color: \(error)") }
//            cell.backgroundColor = color
//            cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "goToNotes", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! NoteTableViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categories?[indexPath.row]
        }
    }
    
    //MARK: - Button Actions
    
    @IBAction func addCategory(_ sender: UIBarButtonItem) {
        
        var txtCategoryName = UITextField()
        
        let alertBox = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        
        let addAction = UIAlertAction(title: "Add", style: .default) { (action) in
            if (txtCategoryName.text != nil) {
                let category = Category()
                category.name = txtCategoryName.text!
//                category.color = UIColor.randomFlat.hexValue()
                
                self.save(category: category)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (cancelAction) in
            return
        }

        alertBox.addAction(addAction)
        alertBox.addAction(cancelAction)
        alertBox.addTextField { (field) in
            txtCategoryName = field
            txtCategoryName.placeholder = "Add a new category"
        }
        
        present(alertBox, animated: true, completion: nil)
        
    }
    
    //MARK: - CRUD
    
    func save(category: Category){
        do {
            try realm.write {
                realm.add(category)
            }
        } catch {
            print("Error saving category: \(error)")
        }
        
        tableView.reloadData()
    }
    
    func loadAllCategories(){
        categories = realm.objects(Category.self)
        tableView.reloadData()
    }
    
    override func delete(at indexPath: IndexPath) {
        if let category = categories?[indexPath.row] {
            
            var message = ""
            
            if category.notes.count > 0 {
                message = "Are you sure? This category has \(category.notes.count) note(s)."
            }
            
            let alertBox = UIAlertController(title: "Delete Category", message: message, preferredStyle: .alert)
            
            let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (action) in
                
                do {
                    try self.realm.write {
                        // show a alert with the count of all notes associated
                        self.realm.delete(category)
                        // delete also the notes associated
                        self.loadAllCategories()
                    }
                } catch {
                    print("Error deleting category: \(error)")
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

}

