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
                
                let urls = fileContent.split(separator: "\n").map{ URL(string: $0.str)! }
                let images = self.getLoadedAndNotLoadedImages(for: urls)
                
                observer.onNext(images.loaded + images.notLoaded)
            } catch let error {
                print(error)
            }
            return Disposables.create()
        }
    }
    
    private func getLoadedAndNotLoadedImages(for urls: [URL]) -> (loaded: [Image], notLoaded: [Image]) {
        let loadedURLSet = Set(UserDefaults.standard.getCachedUrls())
        let URLSet = Set(urls)
        
        let notLoadedImages = URLSet.subtracting(loadedURLSet).map { Image(url: $0, state: .notLoaded) }
        let loadedImages = loadedURLSet.intersection(URLSet).map { Image(url: $0, state: .loaded) }
        
        return (loaded: loadedImages, notLoaded: notLoadedImages)
    }
    
}
