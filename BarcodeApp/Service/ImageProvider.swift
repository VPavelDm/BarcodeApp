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
    
    func getImages() -> Observable<[Image]> {
        return Observable.create { [weak self] observer in
            defer { observer.onCompleted() }
            guard let `self` = self else { return Disposables.create() }
            let urls = self.readFromFile().map{ URL(string: $0)! }
            let images = self.getImages(for: urls)
            
            observer.onNext((images.loaded + images.notLoaded + images.processed).sorted(by: { frst, scnd in
                return frst.url.absoluteString < scnd.url.absoluteString
            }))
            return Disposables.create()
        }
    }
    
    private func readFromFile() -> [String] {
        do {
            let filePath = Bundle.main.url(forResource: "Urls", withExtension: "txt")!
            let fileContent = try String(contentsOf: filePath)
            return fileContent.split(separator: "\n").map { $0.str }
        } catch let error {
            print(error)
        }
        return []
    }
    
    private func getImages(for urls: [URL]) -> (loaded: [Image], notLoaded: [Image], processed: [Image]) {
        let loadedURLSet = urlCache.getCachedItems().toSet
        let processedDictionary = getBarcodesWithTheirUrl()
        let processedURLSet = processedDictionary.map { $0.key }
        let URLSet = Set(urls)
        
        let notLoadedImages = URLSet.subtracting(loadedURLSet).map { Image(url: $0, state: .notLoaded) }
        let loadedImages    = loadedURLSet.intersection(URLSet).subtracting(processedURLSet).map { Image(url: $0, state: .loaded) }
        let processedImages = processedDictionary.map { Image(url: $0.key, state: .processed, barcodes: $0.value) }
        
        return (loaded: loadedImages, notLoaded: notLoadedImages, processed: processedImages)
    }
    
    private func getBarcodesWithTheirUrl() -> [URL: [Barcode]] {
        let barcodeDAO = BarcodeDAO()
        return barcodeDAO.getBarcodesWithURL()
    }
    
    private let urlCache: URLCache = URLCache.instance
    
}
