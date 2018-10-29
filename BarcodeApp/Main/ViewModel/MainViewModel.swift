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
    lazy var dataObservable: Completable = Completable.create { [weak self] observer in
        if let `self` = self {
            self.imageProvider.getData()
                .observeOn(MainScheduler.instance)
                .subscribeOn(ConcurrentDispatchQueueScheduler.init(qos: .userInitiated))
                .subscribe { [weak self] images in
                    guard let `self` = self, let images = images.element else { return }
                    self.cells += images.filter { $0.state == .notLoaded }.map { .notLoaded($0.url.absoluteString) }
                    self.cells += images.filter { $0.state == .loaded    }.map { .loaded($0.url.absoluteString) }
                    self.cells += images.filter { $0.state == .processed }.map { .processed($0.barcodes.count) }
                    
                    observer(.completed)
                }
                .disposed(by: self.disposeBag)
        }
        return Disposables.create()
    }
    
    private let imageProvider = ImageProvider()
    private let disposeBag = DisposeBag()
    
}

enum CellViewModel {
    case notLoaded(String)
    case loaded(String)
    case processed(Int)
}
