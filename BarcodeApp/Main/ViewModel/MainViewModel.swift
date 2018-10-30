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
        guard let `self` = self else { return Disposables.create() }
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
        return Disposables.create()
    }
    
    func loadImage(with urlString: String) -> Single<[Int]> {
        return Single.create { [weak self] observer in
            if let `self` = self, let url = URL(string: urlString) {
                self.loadImage(url: url, observer: observer)
            } else {
                observer(.error(URLCastError()))
            }
            return Disposables.create()
        }
    }
    
    private let imageLoader = ImageLoader()
    private let imageProvider = ImageProvider()
    private let disposeBag = DisposeBag()
    
    private func loadImage(url urlParam: URL, observer: @escaping (SingleEvent<[Int]>) -> ()) {
        imageLoader.downloadImage(with: urlParam)
            .observeOn(MainScheduler.instance)
            .subscribeOn(ConcurrentDispatchQueueScheduler.init(qos: .userInitiated))
            .subscribe(onSuccess: { [weak self] (image) in
                guard let `self` = self else { return }
                
                var indexes = [Int]()
                
                self.cells = self.cells.enumerated().map { (index, cell) -> CellViewModel in
                    if case .notLoaded(let url) = cell, URL(string: url) == urlParam {
                        indexes += [index]
                        return .loaded(url)
                    } else {
                        return cell
                    }
                }
                
                observer(.success(indexes))
                }, onError: { (error) in
                    observer(.error(error))
            }).disposed(by: disposeBag)
    }
    
}

enum CellViewModel {
    case notLoaded(String)
    case loaded(String)
    case processed(Int)
}
