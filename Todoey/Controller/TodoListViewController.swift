//
//  ViewController.swift
//  Todoey
//

import UIKit
import RealmSwift
import ChameleonFramework

class TodoListViewController: SwipeTableViewController{
    
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
        
        tableView.rowHeight = 80.0
        tableView.separatorStyle = .none
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        configureNavigationBar(largeTitleColor: .white, backgoundColor: UIColor(hexString: selectedCategory!.hexColour) ?? UIColor.systemBlue, tintColor: .white, title: selectedCategory?.name ?? "Items", preferredLargeTitle: true)
//        searchBar.searchBarStyle = .minimal
        searchBar.barTintColor = UIColor(hexString: selectedCategory!.hexColour) ?? UIColor.green
        searchBar.searchTextField.placeholder = "Search \(selectedCategory?.name ?? "Items")"
    }
    //MARK: - TableView DataSource Methods
    
    // Return the number of rows for the table.
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }
    
    // Provide a cell object for each row.
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Fetch a cell of the appropriate type.
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        // Cosnfigure the cell’s contents.
        if let item = todoItems?[indexPath.row] {
            let color = UIColor(hexString: selectedCategory!.hexColour)?.darken(byPercentage: CGFloat(CGFloat(indexPath.row) / (CGFloat(todoItems!.count)/0.30)))
//            CGFloat(CGFloat(indexPath.row) / CGFloat(todoItems!.count))           ////MY VERSION
//            CGFloat(Double(indexPath.row) * 0.10)                                 ////ANGELA VERSION
                
            cell.textLabel?.text = item.title
            cell.textLabel?.textColor = ContrastColorOf(color!, returnFlat: true)
            cell.backgroundColor = color
            cell.accessoryType = item.done ? .checkmark : .none
            
        }else{
            cell.textLabel?.text = "No Items Added"
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
//                    realm.delete(item)          //to delete item
                }
            }catch{
                print("update error: \(error)")
            }
        }
        self.tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    //MARK: - Add Button Function
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
    //MARK: - Data Manupulation
    func loadItems(){
        todoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
        self.tableView.reloadData()
    }
    //MARK: - Delete Data from Swipe
    override func updateModel(at indexPath: IndexPath) {
        if let itemForDeletion = self.todoItems?[indexPath.row]{
            do{
                try self.realm.write{
                    self.realm.delete(itemForDeletion)          //to delete item
                }
            }catch{
                print("update error: \(error)")
            }
        }
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
}
