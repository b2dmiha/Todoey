//
//  ViewController.swift
//  Todoey
//
//  Created by Michael Gimara on 08/04/2019.
//  Copyright © 2019 Michael Gimara. All rights reserved.
//

import UIKit
import CoreData

class TodoListTableViewController: UITableViewController {
    
    //MARK: - Variables
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var items = [Item]()

    var addItemAlert: UIAlertController!
    
    //MARK: - Outlets
    @IBOutlet weak var searchBar: UISearchBar!
    
    //MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
    
        configureTableView()
        configureAddItemAlert()
        configureSearchBar()
        loadItems()
    }
    
    //MARK: - CRUD Methods
    func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest()) {
        do {
            self.items = try context.fetch(request)
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        } catch let error {
            print(error.localizedDescription)
        }
    }

    func saveItems() {
        do {
            try context.save()

            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        } catch let error {
            print(error.localizedDescription)
        }
    }

    //MARK: - Custom Methods
    func configureTableView() {
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80.0
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tableView.addGestureRecognizer(panGesture)
    }
    
    @objc func hideKeyboard() {
        DispatchQueue.main.async {
            self.searchBar.endEditing(true)
        }
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

            let newItem = Item(context: self.context)
            newItem.title = itemText
            newItem.done = false

            self.items.append(newItem)
            
            self.saveItems()
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
    
    func configureSearchBar() {
        searchBar.delegate = self
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
    }
    
    //MARK: - Actions
    @IBAction func addItemPressed(_ sender: UIBarButtonItem) {
        present(addItemAlert, animated: true, completion: nil)
    }
}

//MARK: - TextField Delegate Methods
extension TodoListTableViewController: UITextFieldDelegate {
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

//MARK: - SearchBar Delegate Methods
extension TodoListTableViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

        let request: NSFetchRequest<Item> = Item.fetchRequest()
        
        if !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            request.predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchText)
            request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        }

        loadItems(with: request)
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        DispatchQueue.main.async {
            self.searchBar.endEditing(true)
        }
    }
}


