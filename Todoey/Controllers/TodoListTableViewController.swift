//
//  ViewController.swift
//  Todoey
//
//  Created by Michael Gimara on 08/04/2019.
//  Copyright © 2019 Michael Gimara. All rights reserved.
//

import UIKit
import RealmSwift

class TodoListTableViewController: UITableViewController {
    
    //MARK: - Variables
    let realm = try! Realm()
    
    var selectedCategory: Category! {
        didSet {
            loadItems()
        }
    }
    
    var items: Results<Item>?

    var addItemAlert: UIAlertController!
    
    //MARK: - Outlets
    @IBOutlet weak var searchBar: UISearchBar!
    
    //MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
    
        configureTableView()
        configureAddItemAlert()
        configureSearchBar()
    }
    
    //MARK: - CRUD Methods
    func loadItems() {
        items = selectedCategory.items.sorted(byKeyPath: "dateCreated", ascending: true)

        DispatchQueue.main.async {
            self.tableView.reloadData()
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
            
            do {
                try self.realm.write {
                    let newItem = Item()
                    newItem.title = itemText
                    newItem.done = false
                    newItem.dateCreated = Date()
                    
                    self.selectedCategory.items.append(newItem)
                    
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            } catch let error {
                print(error.localizedDescription)
            }
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
        if let items = self.items,
           items.count > 0 {
            return items.count
        }
        
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let itemCell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        
        if let items = self.items,
           items.count > 0 {
            let item = items[indexPath.row]
            itemCell.textLabel?.text = item.title
            itemCell.accessoryType = item.done ? .checkmark : .none
            itemCell.isUserInteractionEnabled = true
        } else {
            itemCell.textLabel?.text = "No Items Added Yet"
            itemCell.accessoryType = .none
            itemCell.isUserInteractionEnabled = false
        }

        return itemCell
    }
    
    //MARK: - TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let selectedItem = items?[indexPath.row] {
            do {
                try self.realm.write {
                    selectedItem.done = !selectedItem.done
  
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            } catch let error {
                print(error.localizedDescription)
            }
        }
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
        if !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            items = selectedCategory.items.filter("title CONTAINS[cd] %@", searchText).sorted(byKeyPath: "title", ascending: true)
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        } else {
            loadItems()
        }
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        DispatchQueue.main.async {
            self.searchBar.endEditing(true)
        }
    }
}


