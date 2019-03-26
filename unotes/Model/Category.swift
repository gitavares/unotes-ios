//
//  Category.swift
//  unotes
//
//  Created by Giselle Tavares on 2019-03-18.
//  Copyright © 2019 Giselle Tavares. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var color: String = ""
    let notes = List<Note>()
}
