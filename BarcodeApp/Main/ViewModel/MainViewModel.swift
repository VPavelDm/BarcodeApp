//
//  MainViewModel.swift
//  BarcodeApp
//
//  Created by mac-089-71 on 10/25/18.
//  Copyright © 2018 VPavelDm. All rights reserved.
//

import Foundation
import RxSwift
import Firebase

class MainViewModel {
    
    var cells: [CellViewModel] = []
    
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
    
    private var downloads: [URL: Download] = [:]
    private let imageProvider = ImageProvider()
    private let imageLoader = ImageLoader()
    private let imageFileManager = ImageFileManager()
    private let disposeBag = DisposeBag()
    
}

extension MainViewModel {
    
    func getData() -> Completable {
        return Completable.create { [weak self] observer in
            guard let `self` = self else { return Disposables.create() }
            self.imageProvider.getData()
                .subscribe { [weak self] images in
                    guard let `self` = self, let images = images.element else { return }
                    self.cells += images.filter { $0.state == .notLoaded }.map { .notLoaded($0.url) }
                    self.cells += images.filter { $0.state == .loaded    }.map { .loaded($0.url) }
                    self.cells += images.filter { $0.state == .processed }.map { .processed($0.barcodes.count) }
                    
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
                self.cells = self.cells.enumerated().map { (index, cell) -> CellViewModel in
                    if case .notLoaded(let caseURL) = cell, caseURL == url {
                        return .loaded(url)
                    } else {
                        return cell
                    }
                }
                }, onSubscribed: { [weak self] in
                    self?.imageLoader.downloadImage(with: url)
            })
    }
    
    func getProgress(for url: URL) -> Float {
        return downloads[url]?.currentProgress ?? 0
    }
    
}

extension MainViewModel {
    
    func findBarcodes(url: URL) -> Completable {
        return Completable.create { [weak self] observer in
            guard
                let `self` = self,
                let localURL = UserDefaults.standard.getLocalUrl(for: url),
                let imageData = self.imageFileManager.readImage(with: localURL),
                let image = VisionImage.create(by: imageData)
                else { return Disposables.create() }
            let vision = Vision.vision()
            let barcodeOptions = VisionBarcodeDetectorOptions(formats: [.qrCode])
            let barcodeDetector = vision.barcodeDetector(options: barcodeOptions)
            barcodeDetector.detect(in: image, completion: { (barcodes, error) in
                guard error == nil, let barcodes = barcodes else { return }
                // MARK: Save barcodes to the CoreData
                self.cells = self.cells.enumerated().map { (index, cell) -> CellViewModel in
                    if case .loaded(let caseURL) = cell, caseURL == url {
                        return .processed(barcodes.count)
                    } else {
                        return cell
                    }
                }
                for barcode in barcodes {
                    guard let corners = barcode.cornerPoints else { continue }
                    for corner in corners {
                        print(corner)
                    }
                }
                observer(.completed)
            })
            return Disposables.create()
        }
    }
    
}

enum CellViewModel {
    case notLoaded(URL)
    case loaded(URL)
    case processed(Int)
}
