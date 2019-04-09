//
//  Item.swift
//  Todoey
//
//  Created by Michael Gimara on 09/04/2019.
//  Copyright © 2019 Michael Gimara. All rights reserved.
//

import Foundation

class Item: Codable {
    var title: String
    var done: Bool
    
    init(title: String, done: Bool = false) {
        self.title = title
        self.done = done
    }
}
