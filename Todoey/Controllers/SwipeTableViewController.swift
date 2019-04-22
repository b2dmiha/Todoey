//
//  SwipeTableViewController.swift
//  Todoey
//
//  Created by Michael Gimara on 20/04/2019.
//  Copyright © 2019 Michael Gimara. All rights reserved.
//

import UIKit
import SwipeCellKit

class SwipeTableViewController: UITableViewController, SwipeTableViewCellDelegate {

    //MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func deleteObject(at indexPath: IndexPath) {
    }
    
    //MARK: - TableView DataSource Methods
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let swipeCell = tableView.dequeueReusableCell(withIdentifier: "SwipeCell", for: indexPath) as! SwipeTableViewCell
        swipeCell.delegate = self
        
        return swipeCell
    }
    
    //MARK: - SwipeTableViewCell Delegate Methods
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        
        guard orientation == .right else { return nil }
        
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { (action, indexPath) in

            self.deleteObject(at: indexPath)
        }
        
        deleteAction.image = UIImage(named: "delete")

        return [deleteAction]
    }
    
//    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
//
//        var options = SwipeOptions()
//        options.expansionStyle = .destructive
//        options.transitionStyle = .border
//
//        return options
//    }
}



