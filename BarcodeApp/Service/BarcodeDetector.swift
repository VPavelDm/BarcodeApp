//
//  BarcodeDetector.swift
//  BarcodeApp
//
//  Created by mac-089-71 on 11/12/18.
//  Copyright © 2018 VPavelDm. All rights reserved.
//

import Foundation
import RxSwift

protocol BarcodeDetector {
    func findBarcodes(with imageData: Data) -> Single<[Barcode]>
}
