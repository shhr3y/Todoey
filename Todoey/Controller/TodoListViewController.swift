//
//  ViewController.swift
//  Todoey
//

import UIKit

class TodoListViewController: UITableViewController{
    
    var itemArray = [Item]()
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(dataFilePath!)
        
        let newItem1 = Item()
        newItem1.title = "Shrey"
        newItem1.done = true
        itemArray.append(newItem1)
        
        let newItem2 = Item()
        newItem2.title = "Aakanksha"
        itemArray.append(newItem2)
        
        
        loadItems()
        
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
        self.saveItems()
        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    //MARK: - Add new items
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add new Todoey Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            //Below code will be executed when the user clicks add item in the UIAlert
            if textField.text != "" {
                
                let newItem = Item()
                newItem.title = textField.text!
                
                self.itemArray.append(newItem)
                
                //saving data using user
                self.saveItems()
                
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
    
    func saveItems(){
        let encoder = PropertyListEncoder()
        do{
            let data = try encoder.encode(itemArray)
            try data.write(to: dataFilePath!)
        }catch{
            print(error)
        }
    }
    
    func loadItems(){
        do{
            if let data = try? Data(contentsOf: dataFilePath!){
                let decoder = PropertyListDecoder()
                itemArray = try decoder.decode([Item].self, from: data)
            }
        }catch{
            print(error)
        }
    }
}


