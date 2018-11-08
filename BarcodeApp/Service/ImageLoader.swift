//
//  ImageLoader.swift
//  BarcodeApp
//
//  Created by mac-089-71 on 10/29/18.
//  Copyright © 2018 VPavelDm. All rights reserved.
//

import Foundation
import RxSwift

class ImageLoader: NSObject {
    
    override init() {
        super.init()
        let urlSessionConfiguration = URLSessionConfiguration.default
        urlSessionConfiguration.urlCache = URLCache.instance
        urlSessionConfiguration.httpMaximumConnectionsPerHost = 5
        urlSession = URLSession(configuration: urlSessionConfiguration, delegate: self, delegateQueue: nil)
    }
    
    var progressObservable: Observable<ProgressType> {
        return progressSubject
    }
    
    func downloadImage(with url: URL) {
        let request = URLRequest(url: url)
        if let urlCache = urlSession.configuration.urlCache, let _ = urlCache.cachedResponse(for: request) {
            completeDownloading(url: url)
        } else {
            let downloadTask = urlSession.downloadTask(with: request)
            downloadTask.resume()
        }
    }
    
    private var urlSession: URLSession!
    private let progressSubject = PublishSubject<ProgressType>()
    
    private func completeDownloading(url sourceURL: URL) {
        progressSubject.onNext((url: sourceURL, progress: 1.0, error: nil))
    }
    
    typealias ProgressType = (url: URL?, progress: Float?, error: Error?)
    
}

extension ImageLoader: URLSessionDownloadDelegate {
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        guard let sourceURL = downloadTask.originalRequest?.url else { return }
        if let urlCache = session.configuration.urlCache {
            urlCache.cacheData(at: location, task: downloadTask)
            completeDownloading(url: sourceURL)
        } else {
            fatalError("URLCache is not set.")
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        guard let url = downloadTask.originalRequest?.url else { return }
        let progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
        if progress != 1.0 {
            self.progressSubject.onNext((url: url, progress: progress, error: nil))
        }
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            progressSubject.onNext((url: nil, progress: nil, error: error))
        }
    }
    
}
