//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Shrey on 27/06/20.
//

import UIKit
import RealmSwift

class CategoryViewController: UITableViewController {
    
    let realm = try! Realm()
    
    var categories: Results<Category>?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadCategories()
    }
    
    // MARK: - TableView DataSource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Fetch a cell of the appropriate type.
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        
        // Configure the cell’s contents.
        cell.textLabel!.text = categories?[indexPath.row].name ?? "No Categories added yet."
        
        return cell
    }
    
    //MARK: - TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: "goToItems", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToItems" {
            let destinationVC = segue.destination as! TodoListViewController
            
            if let indexPath = tableView.indexPathForSelectedRow {
                destinationVC.selectedCategory = categories?[indexPath.row]
            }
        }
    }
    
    
    //MARK: - Add Button Function
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Category", style: .default) { (action) in
            //Below code will be executed when the user clicks add item in the UIAlert
            if textField.text != "" {
                
                let newCategory = Category()
                newCategory.name = textField.text!
                
                //saving data using user
                self.save(category: newCategory)
            }
        }
        
        alert.addAction(action)
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create New Category"
            textField = alertTextField
        }
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Data Manupulation
    
    func save(category:Category){
        do{
            try realm.write{
                realm.add(category)
            }
        }catch{
            print("Error saving categories: ",error)
        }
        self.tableView.reloadData()
    }
    
    func loadCategories(){
        categories = realm.objects(Category.self)
        self.tableView.reloadData()
    }
    
}

