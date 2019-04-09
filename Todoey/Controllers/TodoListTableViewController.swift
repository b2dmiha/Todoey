//
//  ViewController.swift
//  Todoey
//
//  Created by Michael Gimara on 08/04/2019.
//  Copyright © 2019 Michael Gimara. All rights reserved.
//

import UIKit

class TodoListTableViewController: UITableViewController, UITextFieldDelegate {
    
    //MARK: - Variables
    var items = [Item]()
    
    let dataFilePathURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("TodoList.plist")
    
    var addItemAlert: UIAlertController!

    //MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
    
        configureTableView()
        configureAddItemAlert()
        loadItems()
    }
    
    //MARK: - Custom Methods
    func loadItems() {
        if let dataFilePathURL = dataFilePathURL {
            do {
                let data = try Data(contentsOf: dataFilePathURL)
                
                let decoder = PropertyListDecoder()
                self.items = try decoder.decode([Item].self, from: data)
            } catch let error {
                print(error.localizedDescription)
            }
        }
    }
    
    func saveItems() {
        let encoder = PropertyListEncoder()
        
        do {
            let data = try encoder.encode(items)
            
            if let dataFilePathURL = dataFilePathURL {
                try data.write(to: dataFilePathURL)
            }
            
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func configureTableView() {
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80.0
    }
    
    func configureAddItemAlert() {
        addItemAlert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        
        addItemAlert.addTextField { (textField) in
            textField.placeholder = "Enter Todoey Item Description"
            textField.delegate = self
        }
        
        let addItemAction = UIAlertAction(title: "Add Item", style: .default) { (action) in
            guard let textField = self.addItemAlert.textFields?.first,
                  let itemText = textField.text?.trimmingCharacters(in: .whitespaces)
            else { return }
            
            textField.text = ""
            action.isEnabled = false

            let newItem = Item(title: itemText)
            self.items.append(newItem)

            self.saveItems()
            
            self.tableView.reloadData()
        }
        
        addItemAction.isEnabled = false
        
        addItemAlert.addAction(addItemAction)
        
        addItemAlert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: { (action) in
            guard let textField = self.addItemAlert.textFields?.first
            else { return }
            
            textField.text = ""
            
            let addItemAction = self.addItemAlert.actions[0]
            addItemAction.isEnabled = false
        }))
    }
    
    //MARK: - TableView DataSource Methods
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let itemCell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        
        let item = items[indexPath.row]
        
        itemCell.textLabel?.text = item.title
        itemCell.accessoryType = item.done ? .checkmark : .none

        return itemCell
    }
    
    //MARK: - TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        items[indexPath.row].done = !items[indexPath.row].done
        saveItems()
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    //MARK: - Actions
    @IBAction func addItemPressed(_ sender: UIBarButtonItem) {
        present(addItemAlert, animated: true, completion: nil)
    }
    
    //MARK: - TextField Delegate Methods
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        let addItemAction = addItemAlert.actions[0]
        let text = textField.text! + string
        
        if range == NSRange(location: 0, length: 1) ||
           text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            addItemAction.isEnabled = false
        } else {
            addItemAction.isEnabled = true
        }

        return true
    }
}

