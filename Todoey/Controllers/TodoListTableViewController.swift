//
//  ViewController.swift
//  Todoey
//
//  Created by Michael Gimara on 08/04/2019.
//  Copyright © 2019 Michael Gimara. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class TodoListTableViewController: SwipeTableViewController {
    
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.barTintColor = UIColor(hexString: selectedCategory.colorHexString)
        self.navigationItem.title = selectedCategory.name
        
        if let color = UIColor(hexString: selectedCategory.colorHexString),
           let contrastingColor = UIColor(contrastingBlackOrWhiteColorOn: color, isFlat: true) {
            
            self.navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: contrastingColor]
            self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: contrastingColor]
            self.navigationItem.rightBarButtonItem?.tintColor = contrastingColor
            self.navigationController?.navigationBar.items?.first?.backBarButtonItem?.tintColor = contrastingColor
            
            if contrastingColor.hexValue() == "#262626" {
                self.setStatusBarStyle(.default)
            } else {
                self.setStatusBarStyle(.lightContent)
            }
            
            self.searchBar.barTintColor = color
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.setStatusBarStyle(.lightContent)
        self.navigationController?.navigationBar.barTintColor = UIColor(hexString: "#0A84FF")
        self.navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
    }
    
    //MARK: - CRUD Methods
    func loadItems() {
        items = selectedCategory.items.sorted(byKeyPath: "dateCreated", ascending: true)

        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    override func deleteObject(at indexPath: IndexPath) {
        if let item = items?[indexPath.row] {
            do {
                try realm.write {
                    realm.delete(item)
                    
                    DispatchQueue.main.async {
                        self.tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
                    }
                }
            } catch let error {
                print(error.localizedDescription)
            }
        }
    }

    //MARK: - Custom Methods
    func configureTableView() {
        tableView.rowHeight = 80.0
        tableView.separatorStyle = .none
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
        
        let itemCell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let items = self.items,
           items.count > 0 {
            let item = items[indexPath.row]
            itemCell.textLabel?.text = item.title
            itemCell.accessoryType = item.done ? .checkmark : .none

            let darkenPercentage = CGFloat(indexPath.row) / CGFloat(items.count)

            if let color = UIColor(hexString: selectedCategory.colorHexString) {
                itemCell.backgroundColor = color.darken(byPercentage: darkenPercentage)
            } else {
                itemCell.backgroundColor = UIColor.flatSkyBlue()?.darken(byPercentage: darkenPercentage)
            }
            
            if let contrastingColor = UIColor(contrastingBlackOrWhiteColorOn: itemCell.backgroundColor, isFlat: true) {
                itemCell.textLabel?.textColor = contrastingColor
                itemCell.tintColor = contrastingColor
            }

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


