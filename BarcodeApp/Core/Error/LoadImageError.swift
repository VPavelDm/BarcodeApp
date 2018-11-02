//
//  LoadImageError.swift
//  BarcodeApp
//
//  Created by mac-089-71 on 11/1/18.
//  Copyright © 2018 VPavelDm. All rights reserved.
//

import Foundation

class LoadImageError: CustomNSError {
    private let errorMessage: String = "Image can't be loaded."
    
    var errorUserInfo: [String : Any] {
        return [NSLocalizedDescriptionKey: errorMessage]
    }
}
