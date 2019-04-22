//
//  CategoriesTableViewController.swift
//  Todoey
//
//  Created by Michael Gimara on 15/04/2019.
//  Copyright © 2019 Michael Gimara. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class CategoriesTableViewController: SwipeTableViewController {

    //MARK: - Variables
    let realm = try! Realm()
    
    var categories: Results<Category>?
    
    var addCategoryAlert: UIAlertController!
    
    //MARK: - Outlets
    @IBOutlet weak var searchBar: UISearchBar!
    
    //MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        configureTableView()
        configureAddCategoryAlert()
        configureSearchBar()
        loadCategories()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
    }

    //MARK: - CRUD Methods
    func loadCategories() {
        categories = realm.objects(Category.self).sorted(byKeyPath: "dateCreated", ascending: true)

        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func save(category: Category) {
        do {
            try realm.write {
                realm.add(category)
            }

            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        } catch let error {
            print(error.localizedDescription)
        }
    }

    override func deleteObject(at indexPath: IndexPath) {
        if let category = categories?[indexPath.row] {
            do {
                try realm.write {
                    realm.delete(category.items)
                    realm.delete(category)

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

    func configureAddCategoryAlert() {
        addCategoryAlert = UIAlertController(title: "Add New Todoey Category", message: "", preferredStyle: .alert)
        
        addCategoryAlert.addTextField { (textField) in
            textField.placeholder = "Enter Todoey Category Name"
            textField.delegate = self
        }
        
        let addCategoryAction = UIAlertAction(title: "Add Category", style: .default) { (action) in
            guard let textField = self.addCategoryAlert.textFields?.first,
                  let categoryText = textField.text?.trimmingCharacters(in: .whitespaces)
            else { return }
            
            textField.text = ""
            action.isEnabled = false
            
            let newCategory = Category()
            newCategory.name = categoryText
            newCategory.dateCreated = Date()
            newCategory.colorHexString = UIColor.randomColor().hexValue()

            self.save(category: newCategory)
        }
        
        addCategoryAction.isEnabled = false
        
        addCategoryAlert.addAction(addCategoryAction)
        
        addCategoryAlert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: { (action) in
            guard let textField = self.addCategoryAlert.textFields?.first
            else { return }
            
            textField.text = ""
            
            let addCategoryAction = self.addCategoryAlert.actions[0]
            addCategoryAction.isEnabled = false
        }))
    }
    
    func configureSearchBar() {
        searchBar.delegate = self
    }

    //MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier
        else { return }
        
        if identifier == "goToItems" {
            let selectedCategory = sender as! Category
            let destinationVC = segue.destination as! TodoListTableViewController
            destinationVC.selectedCategory = selectedCategory
        }
    }

    // MARK: - TableView DataSource Methods
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let categories = self.categories,
           categories.count > 0 {
            return categories.count
        }
        
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let categoryCell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let categories = self.categories,
           categories.count > 0 {
            let category = categories[indexPath.row]
            categoryCell.textLabel?.text = category.name
            categoryCell.backgroundColor = UIColor(hexString: category.colorHexString)
            categoryCell.isUserInteractionEnabled = true
            
            if let contrastingColor = UIColor(contrastingBlackOrWhiteColorOn: categoryCell.backgroundColor, isFlat: true) {
                categoryCell.textLabel?.textColor = contrastingColor
            }
        } else {
            categoryCell.textLabel?.text = "No Categories Added Yet"
            categoryCell.isUserInteractionEnabled = false
        }

        return categoryCell
    }
    
    // MARK: - TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let selectedCategory = categories?[indexPath.row] {
            performSegue(withIdentifier: "goToItems", sender: selectedCategory)
        }
    }
    
    //MARK: - Actions
    @IBAction func addCategoryPressed(_ sender: UIBarButtonItem) {
        present(addCategoryAlert, animated: true, completion: nil)
    }
}

//MARK: - TextField Delegate Methods
extension CategoriesTableViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let addCategoryAction = addCategoryAlert.actions[0]
        let text = textField.text! + string
        
        if range == NSRange(location: 0, length: 1) ||
            text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            addCategoryAction.isEnabled = false
        } else {
            addCategoryAction.isEnabled = true
        }
        
        return true
    }
}

//MARK: - SearchBar Delegate Methods
extension CategoriesTableViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            categories = realm.objects(Category.self).filter("name CONTAINS[cd] %@", searchText).sorted(byKeyPath: "name", ascending: true)
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        } else {
            loadCategories()
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        DispatchQueue.main.async {
            self.searchBar.endEditing(true)
        }
    }
}
