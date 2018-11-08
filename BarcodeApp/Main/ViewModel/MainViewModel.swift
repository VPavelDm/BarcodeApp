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
    private let disposeBag = DisposeBag()
    
    private func changeCellState(oldState: CellViewModel, newState: CellViewModel, url: URL) {
        self.cells = self.cells.enumerated().map { (index, cell) -> CellViewModel in
            if oldState == cell {
                return newState
            } else {
                return cell
            }
        }
    }
    
}

extension MainViewModel {
    
    func getData() -> Completable {
        return Completable.create { [weak self] observer in
            guard let `self` = self else { return Disposables.create() }
            self.imageProvider.getImages()
                .subscribe { [weak self] images in
                    guard let `self` = self, let images = images.element else { return }
                    images.forEach {
                        switch $0.state {
                        case .loaded:       self.cells += [.loaded($0.url)]
                        case .notLoaded:    self.cells += [.notLoaded($0.url)]
                        case .processed:    self.cells += [.processed($0.url, $0.barcodes.count)]
                        }                        
                    }
                    
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
                self.changeCellState(oldState: .notLoaded(url), newState: .loaded(url), url: url)
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
                let imageData = FileManager.default.readItemLoadedFromNetwork(networkURL: url),
                let image = VisionImage.create(by: imageData)
                else { return Disposables.create() }
            self.getBarcodeDetector().detect(in: image, completion: { (barcodes, error) in
                guard error == nil, let barcodes = barcodes else { return }
                let barcodeDAO = BarcodeDAO()
                for barcode in barcodes {
                    guard let corners = barcode.cornerPoints else { continue }
                    
                    barcodeDAO.save(x1: corners[0].cgPointValue.x.double, y1: corners[0].cgPointValue.y.double,
                                    x2: corners[1].cgPointValue.x.double, y2: corners[1].cgPointValue.y.double,
                                    for: url)
                }
                self.changeCellState(oldState: .loaded(url), newState: .processed(url, barcodes.count), url: url)
                observer(.completed)
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

enum CellViewModel: Equatable {
    case notLoaded(URL)
    case loaded(URL)
    case processed(URL, Int)
    
    static func ==(lhs: CellViewModel, rhs: CellViewModel) -> Bool {
        switch (lhs, rhs) {
        case let (.notLoaded(url1), .notLoaded(url2)):
            return url1 == url2
        case let (.loaded(url1), .loaded(url2)):
            return url1 == url2
        case let (.processed(count1), .processed(count2)):
            return count1 == count2
        default:
            return false
        }
    }
}
