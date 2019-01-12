//
//  MainViewModel.swift
//  BarcodeApp
//
//  Created by mac-089-71 on 10/25/18.
//  Copyright © 2018 VPavelDm. All rights reserved.
//

import Foundation
import RxSwift

class MainViewModel {
    
    init() {
        imageLoader.progressObservable
            .subscribe { [weak self] result in
                guard let `self` = self, let result = result.element else { return }
                if let error = result.error {
                    for download in self.downloads {
                        download.value.sendError(error)
                    }
                } else if let url = result.url, let progress = result.progress, let download = self.downloads[url] {
                    download.updateAndNotifySubscribers(progress: progress)
                }
            }
            .disposed(by: disposeBag)
    }
    
    private var images: [Image] = []
    private var downloads: [URL: Download] = [:]
    private let imageProvider = ImageProvider()
    private let imageLoader = ImageLoader()
    private let mlKitBarcodeDetector: BarcodeDetector = MLKitBarcodeDetector()
    private let coreMLBarcodeDetector: BarcodeDetector = CoreMLBarcodeDetector()
    private let disposeBag = DisposeBag()
    
}

extension MainViewModel {
    
    var imageCount: Int { return images.count }
    
    func getURL(at position: Int) -> URL {
        return images[position].url
    }
    
    func getBarcodeCount(at position: Int) -> Int {
        return images[position].barcodes.count
    }
    
    func isImageNotLoaded(at position: Int) -> Bool {
        return images[position].state == .notLoaded
    }
    
    func isImageLoaded(at position: Int) -> Bool {
        return images[position].state == .loaded
    }
    
    func isImageProcessed(at position: Int) -> Bool {
        return images[position].state == .processed
    }
    
}

extension MainViewModel {
    
    func getData() -> Completable {
        return Completable.create { [weak self] observer in
            guard let `self` = self else { return Disposables.create() }
            self.imageProvider.getImages()
                .subscribe { [weak self] images in
                    guard let `self` = self, let images = images.element else { return }
                    self.images = images
                    
                    observer(.completed)
                }
                .disposed(by: self.disposeBag)
            return Disposables.create()
        }
    }
    
}

extension MainViewModel {
    
    func loadImage(url: URL) -> Observable<Float> {
        let download = Download()
        downloads[url] = download
        return download.progressObservable
            .do(onCompleted: { [weak self] in
                guard let `self` = self else { return }
                self.downloads[url] = nil
                self.images = self.images.map { Image(url: $0.url, state: .loaded) }
            }, onSubscribed: { [weak self] in
                self?.imageLoader.downloadImage(with: url)
            })
    }
    
    func getProgress(for url: URL) -> Float {
        return downloads[url]?.currentProgress ?? 0
    }
    
}

extension MainViewModel {
    
    func findBarcodes(for url: URL) -> Completable {
        let settingsHelper = SettingsBundleHelper()
        switch settingsHelper.getMLType() {
        case .MLKit: return findBarcodes(for: url, by: mlKitBarcodeDetector)
        case .CoreML: return findBarcodes(for: url, by: coreMLBarcodeDetector)
        }
    }
    
    private func findBarcodes(for url: URL, by detector: BarcodeDetector) -> Completable {
        return Completable.create { [weak self] observer in
            guard let `self` = self, let imageData = URLCache.instance.readItem(loadedFrom: url) else { return Disposables.create() }
            detector.findBarcodes(with: imageData)
                .subscribe(onSuccess: { (barcodes) in
                    DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                        guard let `self` = self else { return }
                        let dao = BarcodeDAO()
                        dao.save(barcodes: barcodes, for: url)
                        self.images = self.images.map { Image(url: $0.url, state: .processed, barcodes: barcodes) }
                        observer(.completed)
                    }
                }, onError: { (error) in
                        observer(.error(error))
                })
                .disposed(by: self.disposeBag)
            return Disposables.create()
        }
    }
    
}

extension MainViewModel {
    
    func resetData() -> Completable {
        return Completable.create { [weak self] observer in
            guard let `self` = self else { return Disposables.create() }
            
            URLCache.instance.removeAllCachedResponses()
            
            let cachedURLDao = CachedURLDAO()
            cachedURLDao.removeURLs()
            
            let barcodesDao = BarcodeDAO()
            barcodesDao.removeBarcodes()
            
            self.images = self.images.map { Image(url: $0.url, state: .notLoaded) }
            
            observer(.completed)
            
            return Disposables.create()
        }
        
    }
    
}
