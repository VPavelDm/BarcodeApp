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
    
    var cells: [CellViewModel] = []
    
    init() {
        imageLoader.progressObservable
            .subscribe { [weak self] result in
                guard let `self` = self, let result = result.element, let download = self.downloads[result.url] else { return }
                download.updateAndNotifySubscribers(progress: result.progress)
            }
            .disposed(by: disposeBag)
    }
    
    private var downloads: [URL: Download] = [:]
    private let imageProvider = ImageProvider()
    private let imageLoader = ImageLoader()
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

enum CellViewModel {
    case notLoaded(URL)
    case loaded(URL)
    case processed(Int)
}
