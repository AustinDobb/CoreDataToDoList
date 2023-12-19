//
//  ViewController.swift
//  ToDoist
//
//  Created by Parker Rushton on 10/15/22.
//

import UIKit

class ItemsViewController: UIViewController {

    
    enum TableSection: Int, CaseIterable {
        case incomplete, complete
    }
    
    // MARK: - Outlets
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textField: UITextField!
    
    
    let list: ToDoList
    
    private let itemManager = ItemManager.shared
//    private lazy var datasource: ItemDataSource = {
//        let datasource = ItemDataSource(tableView: tableView) { tableView, indexPath, item in
//            let cell = tableView.dequeueReusableCell(withIdentifier: ItemTableViewCell.reuseIdentifier) as! ItemTableViewCell
//                cell.update(with: item)
//                cell.delegate = self
//                return cell
//            }
//            datasource.delegate = self
//            return datasource
//        }()


    
    
    // MARK: - Properties
    var incompleteItems = [Item]()
    var completedItems = [Item]()


    
    // MARK: - Lifecycle
    init?(code aDecoder: NSCoder, list: ToDoList) {
            self.list = list
            super.init(coder: aDecoder)
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("I'm Dead")
        }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //tableView.dataSource = datasource
        //navigationItem.largeTitleDisplayMode = .never
        //generateNewSnapshot()
        refreshData()
    }
}



// MARK: - Private
extension ItemsViewController {
    
    //    func deleteItem(at indexPath: IndexPath) {
    //            let itemToDelete = item(at: indexPath)
    //            itemManager.remove(itemToDelete)
    //         //   generateNewSnapshot()
    //        }
    
    
    func refreshData(reload: Bool = true) {
        incompleteItems = list.itemsArray.filter { !$0.isCompleted }.sorted(by: { $0.createdAtDate < $1.createdAtDate })
        let completed = list.itemsArray.filter { $0.isCompleted }
        let completedSorted = completed.sorted { first, second in
            guard let firstCompleted = first.completedAt, let secondCompleted = second.completedAt else { return false }
            return firstCompleted < secondCompleted
        }
        self.completedItems = completedSorted
        if reload {
            tableView.reloadData()
        }
    }
    
    //    func refreshData(reload: Bool = true) {
    //        incompleteItems = itemManager.fetchIncompleteItems()
    //        completedItems = itemManager.fetchCompletedItem()
    //        if reload {
    //            tableView.reloadData()
    //        }
    //    }
    
    
    //        func completeButtonPressed(item: Item) {
    //            itemManager.toggleItemCompletion(item)
    //          //  generateNewSnapshot()
    //        }
    
    func item(at indexPath: IndexPath) -> Item {
        let tableSection = TableSection(rawValue: indexPath.section)!
        switch tableSection {
        case .incomplete:
            return incompleteItems[indexPath.row]
        case .complete:
            return completedItems[indexPath.row]
        }
    }
}


// MARK: - TableView DataSource

extension ItemsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let tableSection = TableSection(rawValue: section)!
        switch tableSection {
        case .incomplete:
            return "To-Do (\(incompleteItems.count))"
        case .complete:
            return "Completed (\(completedItems.count))"
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        TableSection.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let tableSection = TableSection(rawValue: section)!
        switch tableSection {
        case .incomplete:
            return incompleteItems.count
        case .complete:
            return completedItems.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ItemTableViewCell.reuseIdentifier) as! ItemTableViewCell
        let item = item(at: indexPath)
        cell.update(with: item)
        return cell
    }

    
    // Swipe to Delete
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        let itemToDelete = item(at: indexPath)
        itemManager.remove(item(at: indexPath))
        //refreshData(reload: false)
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }
    
}

// MARK: - TableView Delegate

extension ItemsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = item(at: indexPath)
        itemManager.toggleItemCompletion(item)
        refreshData()
    }
    
}





//private extension ItemsViewController {
//    
//    func generateNewSnapshot() {
//        // Create a snapshot
//        var snapshot = NSDiffableDataSourceSnapshot<TableSection, Item>()
//        // Fetch incomplete and completed items from Core Data
//       // let incompleteItems = itemManager.incompleteItems(of: list)
//        //let completedItems = itemManager.completedItems(of: list)
//        
//        // If there are incomplete items to show, add them to the tableview
//        if !incompleteItems.isEmpty {
//            snapshot.appendSections([.incomplete])
//            snapshot.appendItems(incompleteItems, toSection: .incomplete)
//        }
//        // If there are completed items to show, add them to the tableview
//        if !completedItems.isEmpty {
//            snapshot.appendSections([.complete])
//            snapshot.appendItems(completedItems, toSection: .complete)
//        }
//        // Apply the snapshot
//        DispatchQueue.main.async {
//            self.datasource.apply(snapshot)
//        }
//    }
//    
//}


// MARK: - TextField Delegate

extension ItemsViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let text = textField.text, !text.isEmpty else { return true }
        itemManager.createNewItem(with: text, in: list)
        refreshData(reload: false)
        tableView.reloadSections([TableSection.incomplete.rawValue], with: .automatic)
        textField.text = ""
        //generateNewSnapshot()
        return true
    }
    
}
