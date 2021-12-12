//
//  Task.swift
//  RealmDBToDo
//
//  Created by Александр Басов on 07/10/2021.
//  Copyright © 2021 Александр Басов. All rights reserved.
//

import Foundation
import RealmSwift

class Task: Object {
    @objc dynamic var name = ""
    @objc dynamic var note = ""
    @objc dynamic var date = Date()
    @objc dynamic var isComplete = false
}
