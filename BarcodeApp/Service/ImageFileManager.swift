//
//  CachedImageService.swift
//  BarcodeApp
//
//  Created by mac-089-71 on 10/29/18.
//  Copyright © 2018 VPavelDm. All rights reserved.
//

import Foundation
import RxSwift

class ImageFileManager {
    
    func save(url: URL, data: Data) -> Completable {
        return Completable.create { [weak self] observer in
            guard let `self` = self else { return Disposables.create() }
            do {
                let cachesDirectory = try FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                let savedUrl = self.getNextCachedName(cachesDirectory: cachesDirectory, for: url)
                try data.write(to: savedUrl, options: [.atomic])
                observer(.completed)
            } catch let error {
                observer(.error(error))
            }
            return Disposables.create()
        }
    }
    
    private let userDefaults = UserDefaults.standard
    
    private func getNextCachedName(cachesDirectory: URL, for url: URL) -> URL {
        let urlName = String(userDefaults.addCachedUrl(url: url))
        let savedUrl = cachesDirectory.appendingPathComponent(urlName)
        return savedUrl
    }
    
}