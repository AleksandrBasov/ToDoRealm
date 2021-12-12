//
//  TasksListViewControllers.swift
//  RealmDBToDo
//
//  Created by Александр Басов on 07/10/2021.
//  Copyright © 2021 Александр Басов. All rights reserved.
//

import UIKit
import RealmSwift

class TasksListViewControllers: UITableViewController {
    
    var tasksLists: Results<TasksList>!
    var NotificationToken: NotificationToken?

    override func viewDidLoad() {
        super.viewDidLoad()
       // StorageManager.deleteAll()
        tasksLists = realm.objects(TasksList.self).sorted(byKeyPath: "name")
        
        //Observer
        NotificationToken = tasksLists.observe { change in
            switch change {
            case .initial:
                print("initial element")
            case .update(_, let deletions, let insertions, let modifications):
                print("deletions: \(deletions)")
                print("insertions: \(insertions)")
                print("modifications: \(modifications)")
                if !modifications.isEmpty {
                    var indexPathArray = [IndexPath]()
                    for row in modifications {
                        indexPathArray.append(IndexPath(row: row, section: 0))
                    }
                    self.tableView.reloadRows(at: indexPathArray, with: .automatic)
                }
            case .error( let error):
                print("error: \(error)")
            }
            
        }
        
        
        navigationItem.leftBarButtonItem = editButtonItem
    }

    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        alertForAddandUpdateList()
    }
    
    @IBAction func sortingList(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            tasksLists = tasksLists.sorted(byKeyPath: "name")
        } else {
            tasksLists = tasksLists.sorted(byKeyPath: "date")
        }
        tableView.reloadData()
    }
    
    
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let currentList = tasksLists[indexPath.row]
        
        let deleteContextItem = UIContextualAction(style: .destructive, title: "Delete") { (_, _, _ ) in
            StorageManager.deleteList(currentList)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        
        let editeContextItem = UIContextualAction(style: .destructive, title: "Edite") { _, _, _ in
            self.alertForAddandUpdateList(currentList, complition: {
                tableView.reloadRows(at: [indexPath], with: .automatic)
            })
        }
        let doneContextItem = UIContextualAction(style: .destructive, title: "Done") { _, _, _ in
            StorageManager.makeAllDone(currentList)
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
        
        let swipeActions = UISwipeActionsConfiguration(actions: [deleteContextItem, editeContextItem, doneContextItem])
        
        editeContextItem.backgroundColor = .orange
        doneContextItem.backgroundColor = .green
        
        return swipeActions
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return tasksLists.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskListCell", for: indexPath)
        let tasksList = tasksLists[indexPath.row]
//        cell.textLabel?.text = tasksList.name
//        cell.detailTextLabel?.text = String(tasksList.tasks.count)
        cell.configure(with: tasksList)
        return cell
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let indexPath = tableView.indexPathForSelectedRow {
            let tasksList = tasksLists[indexPath.row]
            let tasksVC = segue.destination as? TasksViewController
            tasksVC!.currentTasksList = tasksList
        }
    }
    

//    private func alertForAddandUpdateList() {
//        let title = "New list"
//        let message = "Plese insert list name"
//        let doneButton = "Save"
//
//        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
//        var alerttextField: UITextField!
//
//        let saveAction = UIAlertAction(title: doneButton, style: .default) { _ in
//            guard let newList = alerttextField.text, !newList.isEmpty else { return }
//            let taskList = TasksList()
//            taskList.name = newList
//
//            StorageManager.saveTasksList(taskList: taskList)
//            self.tableView.insertRows(at: [IndexPath(row: self.tasksLists.count - 1, section: 0)], with: .automatic)
//        }
//
//        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
//
//        alert.addAction(saveAction)
//        alert.addAction(cancelAction)
//        alert.addTextField { textField in
//            alerttextField = textField
//            alerttextField.placeholder = "List name"
//        }
//
//        present(alert, animated: true)
//    }
//
//}



    private func alertForAddandUpdateList(_ tasksList: TasksList? = nil, complition:(() -> Void)? = nil) {

        let title = tasksList == nil ?  "New list" : "Edit list"
        let message = "Plese insert list name"
        let doneButton = tasksList == nil ? "Save" : "Update"

        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        var alerttextField: UITextField!

        let saveAction = UIAlertAction(title: doneButton, style: .default) { _ in
            guard let newListName = alerttextField.text, !newListName.isEmpty else { return }

            if let tasksList = tasksList {
                StorageManager.editList(tasksList, newListName: newListName)
                if let complition = complition {
                    complition()
                }
            } else {
                let tasksLists = TasksList()
                tasksLists.name = newListName
                
                StorageManager.saveTasksList(taskList: tasksLists)
                self.tableView.insertRows(at: [IndexPath(row: self.tasksLists.count - 1, section: 0)], with: .automatic)
            }
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)

        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        alert.addTextField { textField in
            alerttextField = textField
            alerttextField.placeholder = "List name"
        }

        present(alert, animated: true)
    }

}
