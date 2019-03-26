//
//  Note.swift
//  unotes
//
//  Created by Giselle Tavares on 2019-03-18.
//  Copyright © 2019 Giselle Tavares. All rights reserved.
//

import Foundation
import RealmSwift

class Note: Object {
    @objc dynamic var title: String = ""
    @objc dynamic var note: String?
    @objc dynamic var locationLatitude: String?
    @objc dynamic var locationLongitude: String?
    @objc dynamic var lastImage: String?
    @objc dynamic var createdDate: Date?
    @objc dynamic var modifiedDate: Date?
    var parentCategory = LinkingObjects(fromType: Category.self, property: "notes")
}

