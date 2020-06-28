//
//  ViewController.swift
//  Todoey
//

import UIKit
import CoreData

class TodoListViewController: UITableViewController{
    
    var itemArray = [Item]()
    var selectedCategory: Category? {
        didSet{
            loadItems()
        }
    }
    let context  = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    @IBOutlet var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)) //For Directory where sqlite file is saved
        searchBar.delegate = self
        
    }
    
    //MARK: - TableView DataSource Methods
    
    // Return the number of rows for the table.
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    // Provide a cell object for each row.
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Fetch a cell of the appropriate type.
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        
        // Configure the cell’s contents.
        let item = itemArray[indexPath.row]
        cell.textLabel!.text = item.title
        
        cell.accessoryType = item.done ? .checkmark : .none
        
        return cell
    }
    
    //MARK: - TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
      
//        context.delete(itemArray[indexPath.row])        // HERE ORDER MATTER!
//        itemArray.remove(at: indexPath.row)
        
        self.saveItems()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    //MARK: - Add new items
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add new Todoey Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            //Below code will be executed when the user clicks add item in the UIAlert
            if textField.text != "" {
                
                let newItem = Item(context: self.context)
                newItem.title = textField.text!
                newItem.done = false
                newItem.parentCategory = self.selectedCategory
                
                self.itemArray.append(newItem)
                
                //saving data using user
                self.saveItems()
            }
        }
        
        alert.addAction(action)
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create New Item"
            textField = alertTextField
        }
        present(alert, animated: true, completion: nil)
    }
    
    func saveItems(){
        do{
            try self.context.save()
        }catch{
            print("Error saving context: ",error)
        }
        self.tableView.reloadData()
    }
    
    func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest(), predicate:NSPredicate? = nil){
        
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
        
        if let additonalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [additonalPredicate, categoryPredicate])
        }else{
            request.predicate = categoryPredicate
        }
        
        do{
            itemArray = try context.fetch(request)
        }catch{
            print("Error loading Items: \(error)")
        }
        self.tableView.reloadData()
    }
}

//MARK: - SearchBar Delegate
extension TodoListViewController: UISearchBarDelegate{
    

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {    //For Live Updating
        if searchText == "" {
            loadItems()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
        else{
            let request: NSFetchRequest<Item> = Item.fetchRequest()
            let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
            let sortDescriptor = NSSortDescriptor(key: "title", ascending: true)

            request.sortDescriptors = [sortDescriptor]
            
            loadItems(with: request,predicate: predicate)
        }
    }
    
    //    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {   /// For Search Button Pressed
    //        if searchBar.text != "" {
    //            let request: NSFetchRequest<Item> = Item.fetchRequest()
    //            let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
    //            let sortDescriptor = NSSortDescriptor(key: "title", ascending: true)
    //
    //            request.predicate = predicate
    //            request.sortDescriptors = [sortDescriptor]
    //
    //            do{
    //                itemArray = try context.fetch(request)
    //            }catch{
    //                print("Error loading Items: \(error)")
    //            }
    //            tableView.reloadData()
    //        }
    //    }
}
