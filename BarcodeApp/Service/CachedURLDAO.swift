//
//  CachedURLDAO.swift
//  BarcodeApp
//
//  Created by mac-089-71 on 11/9/18.
//  Copyright © 2018 VPavelDm. All rights reserved.
//

import Foundation
import CoreData

class CachedURLDAO: DAO {
    
    init() {
        super.init(modelName: "URLDataModel")
    }
    
    func saveURLs(urlsToStore: [URL]) {
        let urlEntity = NSEntityDescription.entity(forEntityName: "URLEntity", in: managedContext)!
        urlsToStore.forEach {
            let urlObject = NSManagedObject(entity: urlEntity, insertInto: managedContext)
            urlObject.setValue($0.absoluteString, forKey: "path")
        }
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Can't save: \(error.userInfo)")
        }
    }
    
    func saveURL(urlToStore: URL) {
        saveURLs(urlsToStore: [urlToStore])
    }
    
    func getURLs() -> [URL] {
        let urlsEntity = NSFetchRequest<NSManagedObject>(entityName: "URLEntity")
        
        var urls: [NSManagedObject] = []
        do {
            urls = try managedContext.fetch(urlsEntity)
        } catch let error as NSError {
            print("Can't get urls: \(error.userInfo)")
        }
        let result = urls.map { URL(string: getValue(from: $0, forKey: "path"))! }
        return result
    }
    
    
    
}
