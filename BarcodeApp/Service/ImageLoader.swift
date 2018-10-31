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
        let urlSessionConfiguration = URLSessionConfiguration.ephemeral
        urlSessionConfiguration.httpMaximumConnectionsPerHost = 5
        urlSession = URLSession(configuration: urlSessionConfiguration, delegate: self, delegateQueue: nil)
    }
    
    var progressObservable: Observable<ProgressType> {
        return progressSubject
    }
    
    func downloadImage(with url: URL) {
        let downloadTask = urlSession.downloadTask(with: url)
        downloadTask.resume()
    }
    
    private var urlSession: URLSession!
    private let progressSubject = PublishSubject<ProgressType>()
    
    typealias ProgressType = (url: URL?, progress: Float?, error: Error?)
    
}

extension ImageLoader: URLSessionDownloadDelegate {
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        // MARK: Copy file to the permanent storage
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        guard let url = downloadTask.originalRequest?.url else { return }
        let progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
        self.progressSubject.onNext((url: url, progress: progress, error: nil))
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            progressSubject.onNext((url: nil, progress: nil, error: error))
        }
    }
    
}
