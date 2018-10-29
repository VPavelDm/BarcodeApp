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
        return Observable.create { observer in
            defer { observer.onCompleted() }
            do {
                let filePath = Bundle.main.url(forResource: "Urls", withExtension: "txt")!
                let fileContent = try String(contentsOf: filePath)
                let images = fileContent.split(separator: "\n").map{ URL(string: $0.str)! }.map { Image(url: $0, state: .notLoaded) }
                observer.onNext(images)
            } catch let error {
                print(error)
            }
            return Disposables.create()
        }
    }
    
}
