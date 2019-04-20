//
//  Category.swift
//  Todoey
//
//  Created by Michael Gimara on 20/04/2019.
//  Copyright © 2019 Michael Gimara. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var dateCreated: Date?
    let items = List<Item>()
}
