//
//  Category.swift
//  botcherwidgetExtension
//
//  Created by Martin Velev on 8/24/20.
//

import Foundation
import CoreData

@objc(Category)
class Category: NSManagedObject {
    static func fetchAll(viewContext: NSManagedObjectContext = persistentContainer.viewContext) -> [Category] {
        let request : NSFetchRequest<Category> = Category.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "modificationDate", ascending: false)]
        guard let tasks = try? persistentContainer.viewContext.fetch(request) else {
        return []
        }
        return tasks
    }
    
    
    static func deleteAll(viewContext: NSManagedObjectContext = persistentContainer.viewContext) {
        Category.fetchAll(viewContext: viewContext).forEach({ viewContext.delete($0) })
        try? viewContext.save()
    }
}
