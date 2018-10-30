//
//  ImageLoader.swift
//  BarcodeApp
//
//  Created by mac-089-71 on 10/29/18.
//  Copyright © 2018 VPavelDm. All rights reserved.
//

import Foundation
import RxSwift

class ImageLoader {
    
    func downloadImage(with url: URL) -> Single<Image> {
        return Single.create {observer in
            let dataTask = self.urlSession.dataTask(with: url) { [weak self] (data, response, error) in
                guard let `self` = self else { return }
                if let error = error {
                    observer(.error(error))
                } else if let response = response as? HTTPURLResponse, response.statusCode == 200, let data = data {
                    self.fileManager.save(url: url, data: data)
                        .subscribe(onCompleted: {
                            let image = Image(url: url, state: .loaded)
                            observer(.success(image))
                        }, onError: { (error) in
                            observer(.error(error))
                        }).dispose()
                }
            }
            dataTask.resume()
            return Disposables.create { dataTask.cancel() }
        }
    }
    
    private let fileManager = ImageFileManager()
    private var urlSession: URLSession {
        return URLSession(configuration: .ephemeral)
    }
    
}
