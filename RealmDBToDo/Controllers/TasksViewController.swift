//
//  TasksViewController.swift
//  RealmDBToDo
//
//  Created by Александр Басов on 07/10/2021.
//  Copyright © 2021 Александр Басов. All rights reserved.
//

import UIKit
import RealmSwift

class TasksViewController: UITableViewController {
    
    var currentTasksList: TasksList!
    
    private var currentTasks: Results<Task>!
    private var completedTasks: Results<Task>!

 //1   private var isEditingMode = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = currentTasksList.name
        filteringTasks()
        
        
    }

    // MARK: - Table view data source

    @IBAction func editButtonPressed(_ sender: UIBarButtonItem) {
    //1    isEditingMode.toggle()
    //1    tableView.setEditing(isEditingMode, animated: true)
        tableView.setEditing(!tableView.isEditing, animated: true)
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        alertForAddandUpdateList()
    }
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        section == 0 ? currentTasks.count : completedTasks.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        section == 0 ? "CURRENT TASKS" : "COMPLETED TASKS"
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TasksCell", for: indexPath)
        
        let task = indexPath.section == 0 ? currentTasks[indexPath.row] : completedTasks[indexPath.row]
        
        cell.textLabel?.text = task.name
        cell.detailTextLabel?.text = task.note
        
        return cell
    }
    
//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//
//    }
//
//    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
//        <#code#>
//    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
       let task = indexPath.section == 0 ? currentTasks[indexPath.row] : completedTasks[indexPath.row]
        
        let deleteContextItem = UIContextualAction(style: .destructive, title: "Delete") { (_, _, _ ) in
            StorageManager.deleteTask(task)
            self.filteringTasks()
        }
        
        let editeContextItem = UIContextualAction(style: .destructive, title: "Edite") { _, _, _ in
            self.alertForAddandUpdateList()
        }
        let doneContextItem = UIContextualAction(style: .destructive, title: "Done") { _, _, _ in
            StorageManager.makeDone(task)
            self.filteringTasks()
        }
        
        let swipeActions = UISwipeActionsConfiguration(actions: [deleteContextItem, editeContextItem, doneContextItem])
        
        editeContextItem.backgroundColor = .orange
        doneContextItem.backgroundColor = .green
        
        return swipeActions
    }
    

  
    private func alertForAddandUpdateList(_ taskName: Task? = nil) {

        var title =  "New task"
        let message = "Plese insert task value"
        var doneButton = "Save"
        
        if taskName != nil {
            title = "Edit task"
            doneButton = "Update"
        }
        

        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        var taskTextField: UITextField!
        var noteTextField: UITextField!


        let saveAction = UIAlertAction(title: doneButton, style: .default) { _ in
            guard let newTask = taskTextField.text, !newTask.isEmpty else { return }

            if let taskName = taskName {
                if let newNote = noteTextField.text, !newNote.isEmpty{
                StorageManager.editTask(taskName, newTask: newTask, newNote: newNote)
            } else {
                StorageManager.editTask(taskName, newTask: newTask, newNote: "")
            }
            self.filteringTasks()
        } else {
            let task = Task()
            task.name = newTask
            if let note = noteTextField.text, !note.isEmpty {
                task.note = note
            }
            StorageManager.saveTask(self.currentTasksList, task: task)
            self.filteringTasks()
        }
    }

        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)

        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        alert.addTextField { textField in
            taskTextField = textField
            taskTextField.placeholder = "New task"
            
            if let taskName = taskName {
                taskTextField.text = taskName.name
            }
        }
        alert.addTextField { textField in
            noteTextField = textField
            noteTextField.placeholder = "Note"
            
            if let taskName = taskName {
                noteTextField.text = taskName.note
            }
        }

        present(alert, animated: true)
    }
    
    private func filteringTasks() {
        currentTasks = currentTasksList.tasks.filter("isComplete = false")
        completedTasks = currentTasksList.tasks.filter("isComplete = true")
        tableView.reloadData()
    }
}
