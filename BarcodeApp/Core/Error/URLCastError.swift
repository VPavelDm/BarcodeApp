//
//  URLCastError.swift
//  BarcodeApp
//
//  Created by mac-089-71 on 10/29/18.
//  Copyright © 2018 VPavelDm. All rights reserved.
//

import Foundation

class URLCastError: CustomNSError {
    private let errorMessage: String = "Url not Available."
    
    var errorUserInfo: [String : Any] {
        return [NSLocalizedDescriptionKey: errorMessage]
    }
}
