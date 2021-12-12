//
//  UITableViewCellExtensions.swift
//  RealmDBToDo
//
//  Created by Александр Басов on 08/10/2021.
//  Copyright © 2021 Александр Басов. All rights reserved.
//

import UIKit

extension UITableViewCell {
    func configure(with tasksList: TasksList) {
        let currentTasks = tasksList.tasks.filter("isComplete = false")
        let completedTasks = tasksList.tasks.filter("isComplete = true")

        textLabel?.text = tasksList.name
        
        if !currentTasks.isEmpty {
            detailTextLabel?.text = "\(currentTasks.count)"
            detailTextLabel?.font = UIFont.systemFont(ofSize: 17)
            detailTextLabel?.textColor = .gray
        } else if !completedTasks.isEmpty{
            detailTextLabel?.text = "✓"
            detailTextLabel?.font = UIFont.systemFont(ofSize: 24)
            detailTextLabel?.textColor = .green  // #colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1)
        } else {
            detailTextLabel?.text = "0"
        }
    }
}
