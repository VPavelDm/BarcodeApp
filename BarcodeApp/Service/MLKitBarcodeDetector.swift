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

class MLKitBarcodeDetector: BarcodeDetector {
    
    func findBarcodes(with imageData: Data) -> Single<[Barcode]> {
        return Single.create { [weak self] observer in
            guard let `self` = self, let image = VisionImage.create(by: imageData) else { return Disposables.create() }
            self.semaphore.wait()
            self.getBarcodeDetector().detect(in: image, completion: { [unowned self] (barcodes, error) in
                var resultBarcodes: [Barcode] = []
                if let barcodes = barcodes, error == nil {
                    for barcode in barcodes {
                        let origin = barcode.frame.origin
                        let barcode = Barcode(x1: origin.x.double,
                                              y1: origin.y.double,
                                              x2: origin.x.double + barcode.frame.width.double,
                                              y2: origin.y.double + barcode.frame.height.double)
                        resultBarcodes += [barcode]
                    }
                    observer(.success(resultBarcodes))
                } else if let error = error {
                    observer(.error(error))
                }
                self.semaphore.signal()
            })
            return Disposables.create()
        }
    }
    
    private let semaphore = DispatchSemaphore(value: 2)
    
    private func getBarcodeDetector() -> VisionBarcodeDetector {
        let vision = Vision.vision()
        let barcodeOptions = VisionBarcodeDetectorOptions(formats: VisionBarcodeFormat.all)
        return vision.barcodeDetector(options: barcodeOptions)
    }
    
}
