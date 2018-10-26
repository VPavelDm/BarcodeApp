//
//  ImageProvider.swift
//  BarcodeApp
//
//  Created by mac-089-71 on 10/25/18.
//  Copyright © 2018 VPavelDm. All rights reserved.
//

import Foundation
import RxSwift

class ImageProvider {
    
    func getData() -> Observable<[Image]> {
        return Observable.create { [weak self] observer in
            defer { observer.onCompleted() }
            if let images = self?.images {
                observer.onNext(images)
            }            
            return Disposables.create()
        }
    }
    
    private let images: [Image] = [
        Image(url: URL(string: "https://nekusaka.com/wp-content/uploads/2017/02/Shiba-inu11.jpg")!, state: .loaded),
        Image(url: URL(string: "https://nekusaka.com/wp-content/uploads/2017/02/Shiba-inu11.jpg")!, state: .notLoaded),
        Image(url: URL(string: "https://nekusaka.com/wp-content/uploads/2017/02/Shiba-inu11.jpg")!, state: .processed)
    ]
    
}
