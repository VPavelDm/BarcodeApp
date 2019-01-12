//
//  VisionImage.swift
//  BarcodeApp
//
//  Created by mac-089-71 on 11/1/18.
//  Copyright © 2018 VPavelDm. All rights reserved.
//

import Foundation
import UIKit
import Firebase

extension VisionImage {
    class func create(by data: Data) -> VisionImage? {
        let image = UIImage(data: data)
        if let image = image {
            return VisionImage(image: image)
        } else {
            return nil
        }
    }
}
