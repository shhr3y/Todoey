//
//  ItemModel.swift
//  Todoey
//
//  Created by Shrey on 28/06/20.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import Foundation
import RealmSwift

class Item: Object {
    @objc dynamic var title: String = ""
    @objc dynamic var done: Bool = false
    @objc dynamic var dateCreated: Date? = nil
    var parentCategory = LinkingObjects(fromType: Category.self, property: "items")
}
