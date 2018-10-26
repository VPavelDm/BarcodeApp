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
    
    var loadedObservable: Observable<URL> {
        return loadedSubject
    }
    var notLoadedObservable: Observable<URL> {
        return notLoadedSubject
    }
    var processedObservable: Observable<(url: URL, barcodeCount: Int)> {
        return processedSubject
    }
    
    init() {
        imageProvider.getData()
            .observeOn(MainScheduler.instance)
            .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .userInitiated))
            .subscribe { [weak self] images in
                guard let `self` = self, let images = images.element else { return }
                self.notifyAboutImages(images: images)
            }.disposed(by: disposeBag)
    }
    
    private let loadedSubject = ReplaySubject<URL>.createUnbounded()
    private let notLoadedSubject = ReplaySubject<URL>.createUnbounded()
    private let processedSubject = ReplaySubject<(url: URL, barcodeCount: Int)>.createUnbounded()
    private let imageProvider = ImageProvider()
    private let disposeBag = DisposeBag()
    
    private func notifyAboutImages(images: [Image]) {
        images.forEach {
            switch $0.state {
            case .notLoaded:
                notLoadedSubject.onNext($0.url)
            case .loaded:
                loadedSubject.onNext($0.url)
            case .processed:
                processedSubject.onNext(($0.url, $0.barcodes.count))
            }
        }        
        notLoadedSubject.onCompleted()
        loadedSubject.onCompleted()
        processedSubject.onCompleted()
    }
    
}
