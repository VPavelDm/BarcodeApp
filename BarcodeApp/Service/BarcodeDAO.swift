//
//  BarcodeDAO.swift
//  BarcodeApp
//
//  Created by mac-089-71 on 11/2/18.
//  Copyright © 2018 VPavelDm. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class BarcodeDAO {
    
    func save(barcodes: [Barcode], for url: URL) {
        let barcodeEntity = NSEntityDescription.entity(forEntityName: "BarcodeEntity", in: managedContext)!
        let imageEntity = NSEntityDescription.entity(forEntityName: "ImageEntity", in: managedContext)!
        let image = NSManagedObject(entity: imageEntity, insertInto: managedContext)
        image.setValue(url.absoluteString, forKey: "url")
        let imageBarcodes = image.mutableSetValue(forKey: "barcodes")
        barcodes.forEach {
            let barcode = NSManagedObject(entity: barcodeEntity, insertInto: managedContext)
            barcode.setValue($0.x1, forKey: "x1")
            barcode.setValue($0.y1, forKey: "y1")
            barcode.setValue($0.x2, forKey: "x2")
            barcode.setValue($0.y2, forKey: "y2")
            imageBarcodes.add(barcode)
        }
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Can't save: \(error.userInfo)")
        }
    }
    
    func getBarcodesWithURL() -> [URL: [Barcode]] {
        let imageEntity = NSFetchRequest<NSManagedObject>(entityName: "ImageEntity")

        var result: [URL: [Barcode]] = [:]
        do {
            let images = try managedContext.fetch(imageEntity)
            for image in images {
                let barcodes = image.mutableSetValue(forKey: "barcodes")
                let url = URL(string: image.value(forKey: "url") as! String)!
                result[url] = barcodes.map { item -> Barcode in
                    let item = item as! NSManagedObject
                    let x1: Double = getValue(from: item, forKey: "x1")
                    let y1: Double = getValue(from: item, forKey: "y1")
                    let x2: Double = getValue(from: item, forKey: "x2")
                    let y2: Double = getValue(from: item, forKey: "y2")
                    return Barcode(x1: x1, y1: y1, x2: x2, y2: y2)
                }
            }
        } catch let error as NSError {
            print("Can't get barcode's corners: \(error.userInfo)")
        }
        return result
    }
    
    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "BarcodeDataModel")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                print(error.userInfo)
            }
        })
        return container
    }()
    
    private lazy var managedContext: NSManagedObjectContext = {
        return persistentContainer.newBackgroundContext()
    }()
    
    private func getValue<Type>(from object: NSManagedObject, forKey: String) -> Type {
        let value = object.value(forKey: forKey) as! Type
        return value
    }
    
    private func saveContext() {
        if managedContext.hasChanges {
            do {
                try managedContext.save()
            } catch {
                let nserror = error as NSError
                print(nserror.userInfo)
            }
        }
    }
    
}
