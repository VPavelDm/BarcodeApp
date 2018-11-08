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
        let urlCache = URLCache(memoryCapacity: 100*MB, diskCapacity: 100*MB, diskPath: nil)
        let urlSessionConfiguration = URLSessionConfiguration.default
        urlSessionConfiguration.urlCache = urlCache
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
    private let MB = 1024 * 1024
    
    private func cacheData(at url: URL, session: URLSession, task: URLSessionDownloadTask) {
        let data = FileManager.default.contents(atPath: url.path)
        if let data = data, let response = task.response {
            let request = URLRequest(url: url)
            let urlCache = session.configuration.urlCache ?? URLCache.shared
            let cachedURLResponse = CachedURLResponse(response: response, data: data)
            urlCache.storeCachedResponse(cachedURLResponse, for: request)
        }
    }
    
    private func completeDownloading(url sourceURL: URL) {
        progressSubject.onNext((url: sourceURL, progress: 1.0, error: nil))
    }
    
    typealias ProgressType = (url: URL?, progress: Float?, error: Error?)
    
}

extension ImageLoader: URLSessionDownloadDelegate {
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        guard let sourceURL = downloadTask.originalRequest?.url else { return }
        do {
            try FileManager.default.moveItemLoadedFromNetwork(location: location, networkURL: sourceURL)
            cacheData(at: sourceURL, session: session, task: downloadTask)
            completeDownloading(url: sourceURL)
        } catch let error {
            progressSubject.onNext((url: nil, progress: nil, error: error))
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
