//
//  BarcodeDetector.swift
//  BarcodeApp
//
//  Created by mac-089-71 on 11/8/18.
//  Copyright © 2018 VPavelDm. All rights reserved.
//

import Foundation
import RxSwift
import Firebase

class BarcodeDetector {
    
    func findBarcodes(with imageData: Data) -> Single<[Barcode]> {
        return Single.create { [weak self] observer in
            guard let `self` = self, let image = VisionImage.create(by: imageData) else { return Disposables.create() }
            self.getBarcodeDetector().detect(in: image, completion: { (barcodes, error) in
                var resultBarcodes: [Barcode] = []
                if let barcodes = barcodes, error == nil {
                    for barcode in barcodes {
                        guard let corners = barcode.cornerPoints else { continue }
                        let barcode = Barcode(x1: corners[0].cgPointValue.x.double, y1: corners[0].cgPointValue.y.double,
                                              x2: corners[1].cgPointValue.x.double, y2: corners[1].cgPointValue.y.double)
                        resultBarcodes += [barcode]
                    }
                    observer(.success(resultBarcodes))
                } else if let error = error {
                    observer(.error(error))
                }
            })
            return Disposables.create()
        }
    }
    
    private func getBarcodeDetector() -> VisionBarcodeDetector {
        let vision = Vision.vision()
        let barcodeOptions = VisionBarcodeDetectorOptions(formats: [.qrCode])
        return vision.barcodeDetector(options: barcodeOptions)
    }
    
}
