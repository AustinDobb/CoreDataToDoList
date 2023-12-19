//
//  ItemManager.swift
//  ToDoist
//
//  Created by Parker Rushton on 10/21/22.
//

import Foundation
import CoreData


class ItemManager {
    static let shared = ItemManager()
    
    private let context = PersistenceController.shared.viewContext
    
    var allItems = [Item]()

    // Create
    
    func createNewList(with title: String) {
            let newList = ToDoList(context: context)
            newList.id = UUID().uuidString
            newList.title = title
            newList.createdAt = Date()
            newList.modifiedAt = Date()
            saveContext()
        }
    
    func allLists() -> [ToDoList] {
            let fetchRequest = ToDoList.fetchRequest()
            let sortDescriptor = NSSortDescriptor(key: "modifiedAt", ascending: false)
            fetchRequest.sortDescriptors = [sortDescriptor]
            let fetchedLists = try? context.fetch(fetchRequest)
            return fetchedLists ?? []
        }
    
    
    func deleteList(at indexPath: IndexPath) {
            let list = allLists()[indexPath.row]
            context.delete(list)
            saveContext()
        }
    
    
    func createNewItem(with title: String, in list: ToDoList) {
        let newItem = Item(context: PersistenceController.shared.viewContext)
        newItem.id = UUID().uuidString
        newItem.title = title
        newItem.createdAt = Date()
        newItem.completedAt = nil
        newItem.toDoList = list
        PersistenceController.shared.saveContext()
    }
    
    // Retrieve
    
    func fetchIncompleteItems() -> [Item] {
      return fetchItems(matching: NSPredicate(format: "completedAt == nil"))
  }
    
    func incompleteItems() -> [Item] {
        let incomplete = allItems.filter { $0.completedAt == nil }
        return incomplete.sorted(by: { $0.sortDate >  $1.sortDate })
    }
    
    func fetchCompletedItem() -> [Item] {
        return fetchItems(matching: NSPredicate(format: "completedAt != nil"))
    }
    
    func completedItems() -> [Item] {
        let completed = allItems.filter { $0.completedAt != nil }
        return completed.sorted(by: { $0.sortDate >  $1.sortDate })
    }
    
    // Update
    
    func toggleItemCompletion(_ item: Item) {
//        var updatedItem = item
//        updatedItem.completedAt = item.isCompleted ? nil : Date()
//        if let index = allItems.firstIndex(of: item) {
//            allItems.remove(at: index)
//        }
//        allItems.append(updatedItem)
        item.completedAt = item.isCompleted ? nil : Date()
            saveContext()
    }
    
    // Delete
    
    
    
    func remove(_ item: Item) {
        let context = PersistenceController.shared.viewContext
              context.delete(item)
              saveContext()
    }

    private func item(at indexPath: IndexPath) -> Item {
        let items = indexPath.section == 0 ? fetchIncompleteItems() : fetchCompletedItem()
        return items[indexPath.row]
    }

    
    
    private func saveContext() {
            PersistenceController.shared.saveContext()
        }
    
    
    private func fetchItems(matching predicate: NSPredicate) -> [Item] {
        let fetchRequest = Item.fetchRequest()
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        do {
            let context = PersistenceController.shared.viewContext
            return try context.fetch(fetchRequest)
        } catch {
            print("Error fetch items: \(error)")
            return []
        }
    }

}
