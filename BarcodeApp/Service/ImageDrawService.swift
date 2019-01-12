//
//  ImageDrawService.swift
//  BarcodeApp
//
//  Created by mac-089-71 on 11/9/18.
//  Copyright © 2018 VPavelDm. All rights reserved.
//

import Foundation
import UIKit

class ImageDrawService {
    
    func draw(on image: UIImage, leftTopCorner lt: (x: Double, y: Double), rightBottomCorner rb: (x: Double, y: Double)) -> UIImage {
        // Create a context of the starting image size and set it as the current one
        UIGraphicsBeginImageContext(image.size)
        
        // Draw the starting image in the current context as background
        image.draw(at: CGPoint.zero)
        
        // Get the current context
        let context = UIGraphicsGetCurrentContext()!
        
        // Draw a transparent green Circle
        context.setStrokeColor(UIColor.green.cgColor)
        context.setLineWidth(30.0)
        context.addRect(CGRect(x: lt.x, y: lt.y, width: rb.x - lt.x, height: rb.y - lt.y))
        context.drawPath(using: .stroke) // or .fillStroke if need filling
        
        // Save the context as a new UIImage
        let myImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // Return modified image
        return myImage ?? image
    }
    
}
