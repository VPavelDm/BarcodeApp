//
//  URLCache.swift
//  BarcodeApp
//
//  Created by mac-089-71 on 11/8/18.
//  Copyright © 2018 VPavelDm. All rights reserved.
//

import Foundation

extension URLCache {
    
    func getCachedItems() -> [URL] {
        var urls = UserDefaults.standard.array(forKey: ARRAY_KEY) as? Array<String> ?? []
        urls = urls
            .map { URL(string: $0)! }
            .map { URLRequest(url: $0) }
            .filter { cachedResponse(for: $0) != nil }
            .map { $0.url!.absoluteString }
        UserDefaults.standard.set(urls, forKey: ARRAY_KEY)
        return urls.map { URL(string: $0)! }
    }
    
    func readItem(loadedFrom url: URL) -> Data? {
        let request = URLRequest(url: url)
        let cachedResponse = self.cachedResponse(for: request)
        return cachedResponse?.data
    }
    
    func cacheData(at url: URL, task: URLSessionDownloadTask) {
        if let data = FileManager.default.contents(atPath: url.path), let response = task.response, let url = task.originalRequest?.url {
            let request = URLRequest(url: url)
            let cachedURLResponse = CachedURLResponse(response: response, data: data)
            storeCachedResponse(cachedURLResponse, for: request)
            
            var urls = (UserDefaults.standard.array(forKey: ARRAY_KEY) as? Array<String> ?? []).toSet
            urls.insert(url.absoluteString)
            UserDefaults.standard.set(urls.toArray, forKey: ARRAY_KEY)
        }
    }
    
    private var ARRAY_KEY: String {
        return "CachedURLs"
    }
    private static let MB = 1024 * 1024
    static let instance: URLCache = URLCache(memoryCapacity: 100*MB, diskCapacity: 100*MB, diskPath: nil)
    
}
