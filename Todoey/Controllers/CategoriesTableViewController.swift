//
//  CategoriesTableViewController.swift
//  Todoey
//
//  Created by Michael Gimara on 15/04/2019.
//  Copyright © 2019 Michael Gimara. All rights reserved.
//

import UIKit
import CoreData

class CategoriesTableViewController: UITableViewController {
    
    //MARK: - Variables
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var categories = [Category]()
    
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

//        /* DataModel.sqlite file path */
//        let sqliteFilePath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
//        print(sqliteFilePath)
    }
    
    //MARK: - CRUD Methods
    func loadCategories(with request: NSFetchRequest<Category> = Category.fetchRequest()) {
        do {
            self.categories = try context.fetch(request)
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func saveCategories() {
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
            
            let newCategory = Category(context: self.context)
            newCategory.name = categoryText

            self.categories.append(newCategory)
            
            self.saveCategories()
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
        return categories.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let categoryCell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        
        let category = categories[indexPath.row]
        
        categoryCell.textLabel?.text = category.name

        return categoryCell
    }
    
    // MARK: - TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: categories[indexPath.row])
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
        
        let request: NSFetchRequest<Category> = Category.fetchRequest()
        
        if !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            request.predicate = NSPredicate(format: "name CONTAINS[cd] %@", searchText)
            request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        }
        
        loadCategories(with: request)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        DispatchQueue.main.async {
            self.searchBar.endEditing(true)
        }
    }
}
