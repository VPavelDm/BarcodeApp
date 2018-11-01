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
    
    func move(from fromURL: URL, to toURL: URL) -> Completable {
        return Completable.create { observer in
            do {
                let cachesDirectory = try FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                let savedUrl = self.getNextCachedName(cachesDirectory: cachesDirectory, for: toURL)
                try? FileManager.default.removeItem(at: savedUrl)
                try FileManager.default.copyItem(at: fromURL, to: savedUrl)
            } catch let error {
                print(error.localizedDescription)
            }
            return Disposables.create()
        }
    }
    
    func readImage(with url: URL) -> Data? {
        return FileManager.default.contents(atPath: url.path)
    }
    
    private let userDefaults = UserDefaults.standard
    
    private func getNextCachedName(cachesDirectory: URL, for url: URL) -> URL {
        let urlName = String(userDefaults.addCachedUrl(url: url))
        let savedUrl = cachesDirectory.appendingPathComponent(urlName)
        return savedUrl
    }
    
}
