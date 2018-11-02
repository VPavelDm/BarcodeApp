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
    
    func save(x1: Double, y1: Double, x2: Double, y2: Double, for url: URL) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let leftTopCornerEntity = NSEntityDescription.entity(forEntityName: "LeftTopCorner", in: managedContext)!
        let rightBottomCornerEntity = NSEntityDescription.entity(forEntityName: "RightBottomCorner", in: managedContext)!
        
        let leftTopCorner = NSManagedObject(entity: leftTopCornerEntity, insertInto: managedContext)
        let rightBottomCorner = NSManagedObject(entity: rightBottomCornerEntity, insertInto: managedContext)

        leftTopCorner.setValue(x1, forKey: "x")
        leftTopCorner.setValue(y1, forKey: "y")
        leftTopCorner.setValue(url.absoluteString, forKey: "url")
        
        rightBottomCorner.setValue(x2, forKey: "x")
        rightBottomCorner.setValue(y2, forKey: "y")
        rightBottomCorner.setValue(url.absoluteString, forKey: "url")
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Can't save: \(error.userInfo)")
        }
        
    }
    
    func getBarcodes() -> [(x1: Double, y1: Double, x2: Double, y2: Double, url: URL)] {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return [] }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let leftTopCornerfetchRequest       = NSFetchRequest<NSManagedObject>(entityName: "LeftTopCorner")
        let rightBottomCornerfetchRequest   = NSFetchRequest<NSManagedObject>(entityName: "RightBottomCorner")
        
        var barcodes: [(x1: Double, y1: Double, x2: Double, y2: Double, url: URL)] = []
        
        do {
            let leftTopCorners      = try managedContext.fetch(leftTopCornerfetchRequest)
            let rightBottomCorners  = try managedContext.fetch(rightBottomCornerfetchRequest)
            
            assert(leftTopCorners.count == rightBottomCorners.count)
            
            var i = 0
            while i < leftTopCorners.count {
                let leftTopCorner           = getCoordinates(from: leftTopCorners[i])
                let rightBottomCorner       = getCoordinates(from: rightBottomCorners[i])
                let leftTopCornerURL:String = getValue(from: leftTopCorners[i], forKey: "url")
                
                barcodes += [(x1:   leftTopCorner.x,      y1: leftTopCorner.y,
                              x2:   rightBottomCorner.x,  y2: rightBottomCorner.y,
                              url:  URL(string: leftTopCornerURL)!)]
                
                i += 1
            }
        } catch let error as NSError {
            print("Can't get barcode's corners: \(error.userInfo)")
        }
        return barcodes
    }
    
    private func getCoordinates(from object: NSManagedObject) -> (x: Double, y: Double) {
        return (x: getValue(from: object, forKey: "x"), y: getValue(from: object, forKey: "y"))
    }
    
    private func getValue<Type>(from object: NSManagedObject, forKey: String) -> Type {
        let value = object.value(forKey: forKey) as! Type
        return value
    }
    
}
