//
//  ViewController.swift
//  BarcodeApp
//
//  Created by mac-089-71 on 11/5/18.
//  Copyright © 2018 VPavelDm. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    
    class func createViewController<Controller>(asClass: Controller.Type) -> Controller {
        let storyboard = UIStoryboard(name: String(describing: asClass), bundle: nil)
        let viewController = storyboard.instantiateInitialViewController() as? Controller
        assert(viewController != nil, "Each ViewController must be initial")
        return viewController!
    }
    
}
