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
            let dataTask = self.urlSession.dataTask(with: url) { (data, response, error) in
                DispatchQueue.main.async {
                    if let error = error {
                        observer(.error(error))
                    } else if let response = response as? HTTPURLResponse, response.statusCode == 200, let data = data {
                        // MARK: Cache data
                        let image = Image(url: url, state: .loaded)
                        observer(.success(image))
                    }
                }
            }
            dataTask.resume()
            return Disposables.create { dataTask.cancel() }
        }
    }
    
    private var urlSession: URLSession {
        return URLSession(configuration: .ephemeral)
    }
    
}
