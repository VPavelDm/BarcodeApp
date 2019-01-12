//
//  UIAlertController.swift
//  BarcodeApp
//
//  Created by mac-089-71 on 10/31/18.
//  Copyright © 2018 VPavelDm. All rights reserved.
//

import Foundation
import UIKit

extension UIAlertController {
    
    convenience init(with error: Error) {
        self.init(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .cancel)
        addAction(action)
    }
    
}
