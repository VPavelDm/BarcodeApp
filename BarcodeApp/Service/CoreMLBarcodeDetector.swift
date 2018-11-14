//
//  CoreMLBarcodeDetector.swift
//  BarcodeApp
//
//  Created by mac-089-71 on 11/12/18.
//  Copyright © 2018 VPavelDm. All rights reserved.
//

import Foundation
import RxSwift
import CoreML

class CoreMLBarcodeDetector: BarcodeDetector {
    
    init() {
        let options: [String: Any] = [CIDetectorAccuracy: CIDetectorAccuracyHigh, CIDetectorAspectRatio: 1.0]
        detector = CIDetector(ofType: CIDetectorTypeQRCode, context: nil, options: options)
    }
    
    func findBarcodes(with imageData: Data) -> Single<[Barcode]> {
        return Single.create { [weak self] observer in
            var resultBarcodes: [Barcode] = []
            if let semaphore = self?.semaphore, let detector = self?.detector, let image = self?.convertImage(data: imageData) {
                semaphore.wait()
                let features = detector.features(in: image)
                for feature in features as! [CIQRCodeFeature] {
                    let barcode = Barcode(x1: feature.topLeft.x.double,
                                          y1: feature.topLeft.y.double,
                                          x2: feature.bottomRight.x.double,
                                          y2: feature.bottomRight.y.double)
                    resultBarcodes += [barcode]
                }
                observer(.success(resultBarcodes))
                semaphore.signal()
            }
            return Disposables.create()
        }
    }
    
    private let detector: CIDetector?
    private let semaphore = DispatchSemaphore(value: 2)
    
    private func convertImage(data: Data) -> CIImage? {
        return CIImage(data: data)
    }
    
}
