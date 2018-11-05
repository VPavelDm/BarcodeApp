//
//  Image.swift
//  BarcodeApp
//
//  Created by mac-089-71 on 10/25/18.
//  Copyright © 2018 VPavelDm. All rights reserved.
//

import Foundation

struct Image {
    var url: URL
    var state: ImageState
    var barcodes: [Barcode]
    
    init(url: URL, state: ImageState, barcodes: [Barcode] = []) {
        self.url = url
        self.state = state
        self.barcodes = barcodes
    }
}

enum ImageState {
    case notLoaded
    case loaded
    case processed
}
