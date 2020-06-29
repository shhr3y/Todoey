//
//  CategoryModel.swift
//  Todoey
//
//  Created by Shrey on 28/06/20.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import Foundation
import RealmSwift
import ChameleonFramework

class Category: Object {
    @objc dynamic var name: String = ""
    let items = List<Item>()
    @objc dynamic var hexColour: String = ""
}

