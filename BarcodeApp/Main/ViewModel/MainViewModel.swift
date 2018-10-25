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
    
    var loadedObservable: Observable<Int> {
        return loadedSubject
    }
    var notLoadedObservable: Observable<Int> {
        return notLoadedSubject
    }
    var processedObservable: Observable<Int> {
        return processedSubject
    }
    
    init() {
        imageProvider.getData().subscribe { [weak self] images in
            guard let `self` = self, let images = images.element else { return }
            self.images = images
            self.notifyAboutImages(images: images)            
            }.dispose()
    }
    
    private(set) var images: [Image] = []
    
    private let loadedSubject = BehaviorSubject<(Int)>(value: -1)
    private let notLoadedSubject = BehaviorSubject<(Int)>(value: -1)
    private let processedSubject = BehaviorSubject<(Int)>(value: -1)
    private let imageProvider = ImageProvider()
    
    private func notifyAboutImages(images: [Image]) {
        for (index, image) in images.enumerated() {
            switch image.state {
            case .notLoaded:
                notLoadedSubject.on(.next(index))
            case .loaded:
                loadedSubject.on(.next(index))
            case .processed:
                processedSubject.onNext(index)
            }
        }
        
    }
    
}
