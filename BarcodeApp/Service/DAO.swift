//
//  DAO.swift
//  BarcodeApp
//
//  Created by mac-089-71 on 11/9/18.
//  Copyright © 2018 VPavelDm. All rights reserved.
//

import Foundation
import CoreData

class DAO {
    
    init(modelName: String) {
        self.modelName = modelName
    }
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: modelName)
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                print(error.userInfo)
            }
        })
        return container
    }()
    
    lazy var managedContext: NSManagedObjectContext = {
        return persistentContainer.newBackgroundContext()
    }()
    
    func getValue<Type>(from object: NSManagedObject, forKey: String) -> Type {
        let value = object.value(forKey: forKey) as! Type
        return value
    }
    
    func saveContext() {
        if managedContext.hasChanges {
            do {
                try managedContext.save()
            } catch {
                let nserror = error as NSError
                print(nserror.userInfo)
            }
        }
    }
    
    private let modelName: String
}
