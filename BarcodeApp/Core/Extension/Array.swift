//
//  Array.swift
//  BarcodeApp
//
//  Created by mac-089-71 on 11/8/18.
//  Copyright © 2018 VPavelDm. All rights reserved.
//

import Foundation

extension Array where Element: Hashable {
    
    var toSet: Set<Element> {
        return Set(self)
    }
    
}
