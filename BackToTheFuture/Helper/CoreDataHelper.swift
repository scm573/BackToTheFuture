//
//  CoreDataHelper.swift
//  BackToTheFuture
//
//  Created by Wu, Qifan | Keihan | ECID on 2018/02/04.
//  Copyright © 2018 Wu, Qifan | Keihan | ECID. All rights reserved.
//

import CoreData

class CoreDataHelper {
    static func queryDataOf(entityName: String, predicate: NSPredicate, completionHandler: @escaping(([Any]) -> Void)) {
        let entity = NSEntityDescription.entity(forEntityName: entityName, in: AppDelegate.shared.stack.context)
        
        let request =  NSFetchRequest<NSFetchRequestResult>()
        request.entity = entity
        request.predicate = predicate
        
        do {
            let fetchedObjects = try AppDelegate.shared.stack.context.fetch(request)
            completionHandler(fetchedObjects)
        }
        catch {
            fatalError("Failed when querying \(entityName) data.")
        }
    }
}
