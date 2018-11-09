//
//  BarcodeDescriptionViewModel.swift
//  BarcodeApp
//
//  Created by mac-089-71 on 11/9/18.
//  Copyright © 2018 VPavelDm. All rights reserved.
//

import Foundation
import RxSwift

class BarcodeDescriptionViewModel {
    
    private(set) var barcodes: [Barcode] = []
    
    func loadBarcodes(for url: URL) -> Completable {
        return Completable.create { [weak self] observer in
            guard let `self` = self else { return Disposables.create() }
            let barcodeDAO = BarcodeDAO()
            self.barcodes = barcodeDAO.getBarcodes(for: url)
            observer(.completed)
            return Disposables.create()
        }
    }
    
}
