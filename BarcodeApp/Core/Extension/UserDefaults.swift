//
//  UserDefaults.swift
//  BarcodeApp
//
//  Created by mac-089-71 on 10/30/18.
//  Copyright © 2018 VPavelDm. All rights reserved.
//

import Foundation

extension UserDefaults {
    
    func addCachedUrl(url: URL) {
        var dictionary = self.dictionary(forKey: "cachedUrls") ?? [:]
        dictionary[url.absoluteString] = dictionary.count
        set(dictionary, forKey: "cachedUrls")
    }
    
    func getCachedUrlCount() -> Int {
        return dictionary(forKey: "cachedUrls")?.count ?? 0
    }
    
    func getCachedUrl() -> [URL] {
        let dictionary = self.dictionary(forKey: "cachedUrls") as? Dictionary<String, Int> ?? [:]
        return dictionary.keys.map { URL(string: $0)! }
    }
    
}
