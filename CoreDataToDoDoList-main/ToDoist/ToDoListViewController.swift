//
//  ToDoListViewController.swift
//  ToDoist
//
//  Created by Austin Dobberfuhl on 12/12/23.
//

import UIKit

class ToDoListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    private let manager = ItemManager.shared
    
    @IBOutlet weak var toDoListTableView: UITableView!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        self.toDoListTableView.delegate = self
        self.toDoListTableView.dataSource = self
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        toDoListTableView.reloadData()
    }
    
    func list(at indexPath: IndexPath) -> ToDoList {
            manager.allLists()[indexPath.row]
        }
    
    @IBAction func newListAlert(_ sender: Any) {
           let alert = UIAlertController(title: "Create a new ToDoList", message: nil, preferredStyle: .alert)
           alert.addTextField { tf in
               tf.placeholder = "List name: bills, cleaning tasks, etc."
           }

           let submitAction = UIAlertAction(title: "Submit", style: .default) { [unowned alert] _ in
               guard let textField = alert.textFields?.first, let response = textField.text else { return }
               self.manager.createNewList(with: response)
               self.toDoListTableView.reloadData()
           }
           let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
           alert.addAction(submitAction)
           alert.addAction(cancelAction)
           present(alert, animated: true)
       }
    
    
    @IBSegueAction func showItems(_ coder: NSCoder) -> ItemsViewController? {
        guard let indexPath = toDoListTableView.indexPathForSelectedRow else { return nil }
        toDoListTableView.deselectRow(at: indexPath, animated: true)
        let selectedList = list(at: indexPath)
        return ItemsViewController(code: coder, list: selectedList)
    }
    }
    


extension ToDoListViewController {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return manager.allLists().count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "toDoList", for: indexPath)
        let listAtRow = list(at: indexPath)
        cell.textLabel?.text = listAtRow.title
        cell.detailTextLabel?.text = "\(listAtRow.itemsArray.count) items"
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        manager.deleteList(at: indexPath)
        tableView.deleteRows(at: [indexPath], with: .fade)
    }

}
