//
//  TasksViewController.swift
//  Realm
//
//  Created by Анна Белова on 24.08.2024.
//

import UIKit
import RealmSwift

class TasksViewController: UITableViewController {

    var  taskList: TaskList!
    
    private var currentTasks: Results<Task>!
    private var completedTasks: Results<Task>!
    private let storageManager = StorageManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = taskList.title
        
        let addButton = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addButtonPressed)
        )
        navigationItem.rightBarButtonItems = [addButton, editButtonItem]
        
        currentTasks = taskList.tasks.filter("isComplete = false")
        completedTasks = taskList.tasks.filter("isComplete = true")

    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        section == 0 ? currentTasks.count : completedTasks.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        section == 0 ? "CURRENT TASKS" : "COMPLETED TASKS"
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TasksCell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        let task = indexPath.section == 0 ? currentTasks[indexPath.row] : completedTasks[indexPath.row]
        content.text = task.title
        content.secondaryText = task.note
        cell.contentConfiguration = content
        return cell
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let task: Task
        
        if indexPath.section == 0 {
            task = currentTasks[indexPath.row]
        } else {
            task = completedTasks[indexPath.row]
        }
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [unowned self] _, _, _ in
            storageManager.deleteTask(task)
            self.currentTasks = self.taskList.tasks.filter("isComplete = false")
            self.completedTasks = self.taskList.tasks.filter("isComplete = true")
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        
        let editAction = UIContextualAction(style: .normal, title: "Edit") { [unowned self] _, _, isDone in
            showAlert(with: task) {
                tableView.reloadRows(at: [indexPath], with: .automatic)
            }
            isDone(true)
        }
        editAction.backgroundColor = .orange
        
        if indexPath.section == 0 {
            let doneAction = UIContextualAction(style: .normal, title: "Done") { [unowned self] _, _, isDone in
                storageManager.doneTask(task)
                tableView.performBatchUpdates {
                    self.currentTasks = self.taskList.tasks.filter("isComplete = false")
                    self.completedTasks = self.taskList.tasks.filter("isComplete = true")
                    tableView.deleteRows(at: [indexPath], with: .automatic)
                    if let newRow = self.completedTasks.index(of: task) {
                        tableView.insertRows(at: [IndexPath(row: newRow, section: 1)], with: .automatic)
                    }
                }
                isDone(true)
            }
            doneAction.backgroundColor = .green
            return  UISwipeActionsConfiguration(actions: [doneAction, editAction, deleteAction])
        } else {
            let undoneAction = UIContextualAction(style: .normal, title: "Undone") { [unowned self] _, _, undone in
                storageManager.undoneTask(task)
                tableView.performBatchUpdates {
                    self.currentTasks = self.taskList.tasks.filter("isComplete = false")
                    self.completedTasks = self.taskList.tasks.filter("isComplete = true")
                    tableView.deleteRows(at: [indexPath], with: .automatic)
                    if let newRow = self.currentTasks.index(of: task) {
                        tableView.insertRows(at: [IndexPath(row: newRow, section: 0)], with: .automatic)
                    }
                }
                undone(true)
            }
            undoneAction.backgroundColor = .green
            return UISwipeActionsConfiguration(actions: [undoneAction, editAction, deleteAction])
        }
        
    }
    
    @objc private func addButtonPressed() {
        showAlert()
    }
    
}


extension TasksViewController {
    private func showAlert(with task: Task? = nil, completion: (() -> Void)? = nil) {
        let alertBuilder = AlertControllerBuilder(
            title: task != nil ? "Edit Task" : "New Task",
            message: "What do you want to do?"
        )
        
        alertBuilder
            .setTextField(withPlaceholder: "Task Title", andText: task?.title)
            .setTextField(withPlaceholder: "Note Title", andText: task?.note)
            .addAction(
                title: task != nil ? "Update Task" : "Save Task",
                style: .default
            ) { [weak self] taskTitle, taskNote in
                if let task, let completion {
                    self?.storageManager.editTask(task, newTitle: taskTitle, newNote: taskNote)
                    completion()
                    return
                }
                self?.save(task: taskTitle, withNote: taskNote)
            }
            .addAction(title: "Cancel", style: .destructive)
        
        let alertController = alertBuilder.build()
        present(alertController, animated: true)
    }
    
    private func save(task: String, withNote note: String) {
        storageManager.save(task, withNote: note, to: taskList) { task in
            let indexPath = IndexPath(row: currentTasks.index(of: task) ?? 0, section: 0)
            tableView.insertRows(at: [indexPath], with: .automatic)
        }
    }
}

