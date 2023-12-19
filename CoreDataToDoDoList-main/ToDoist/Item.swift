//
//  Item.swift
//  ToDoist
//
//  Created by Parker Rushton on 10/21/22.
//

import Foundation



extension ToDoList {
    var itemsArray: [Item] {
        items?.allObjects as? [Item] ?? []
    }
//    var itemArray: [Item] {
//        guard let array = items?.allObjects as? [Item] else { return [] }
//        return array
//    }
}

extension Item {
    
    static let entityName = "Item"

    // Computed
    
    var createdAtDate: Date {
        createdAt ?? Date.distantPast
    }
    var isCompleted: Bool {
        completedAt != nil
    }
    var subtitle: String {
        if isCompleted, let completedAtString {
            return completedAtString
        }
        return createdAtString
    }
    var sortDate: Date {
        if isCompleted, let completedAt {
            return completedAt
        }
        return createdAtDate
    }
    var createdAtString: String {
        Item.relativeDateFormatter.localizedString(for: createdAtDate, relativeTo: Date())
    }
    
    var completedAtString: String? {
        guard let completedAt else { return nil }
        return Item.relativeDateFormatter.localizedString(for: completedAt, relativeTo: Date())
    }
    

    
}




// MARK: - Date Formatter

extension Item {
    
    static var relativeDateFormatter: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        formatter.dateTimeStyle = .named
        formatter.unitsStyle = .abbreviated
        formatter.formattingContext = .beginningOfSentence
        return formatter
    }()

}
