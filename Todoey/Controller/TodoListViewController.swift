//
//  ViewController.swift
//  Todoey
//

import UIKit
import RealmSwift

class TodoListViewController: UITableViewController{
    
    var realm = try! Realm()
    
    var todoItems: Results<Item>?
    var selectedCategory: Category? {
        didSet{
            loadItems()
        }
    }
    
    @IBOutlet var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)) //For Directory where sqlite file is saved
        searchBar.delegate = self
        
    }
    
    //MARK: - TableView DataSource Methods
    
    // Return the number of rows for the table.
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }
    
    // Provide a cell object for each row.
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Fetch a cell of the appropriate type.
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        
        // Configure the cell’s contents.
        if let item = todoItems?[indexPath.row] {
            cell.textLabel!.text = item.title
            cell.accessoryType = item.done ? .checkmark : .none
        }else{
            cell.textLabel!.text = "No Items Added"
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    //MARK: - TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let item = todoItems?[indexPath.row]{
            do{
                try realm.write{
                    item.done = !item.done      //to update checkmark
                    realm.delete(item)          //to delete item
                }
            }catch{
                print("update error: \(error)")
            }
        }
        self.tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    //MARK: - Add new items
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add new Todoey Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            //Below code will be executed when the user clicks add item in the UIAlert
            if textField.text != "" {
                if let currentCategory = self.selectedCategory {
                    do{
                        try self.realm.write{                        
                            let newItem = Item()
                            newItem.title = textField.text!
                            newItem.dateCreated = Date()
                            currentCategory.items.append(newItem)
                        }
                    }catch{
                        print(error)
                    }
                }
                self.tableView.reloadData()
            }
        }
        
        alert.addAction(action)
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create New Item"
            textField = alertTextField
        }
        present(alert, animated: true, completion: nil)
    }
    
    func loadItems(){
        todoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
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
            todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
            tableView.reloadData()
        }
    }
    
//    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {   // For Search Button Pressed
//        if searchBar.text != "" {
//            todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "title", ascending: true)
//            print("aagya: \(searchBar.text!)")
//        }else{
//            loadItems()
//            DispatchQueue.main.async {
//                searchBar.resignFirstResponder()
//            }
//        }
//    }
}
