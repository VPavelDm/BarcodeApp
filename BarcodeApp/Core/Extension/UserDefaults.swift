//
//  UserDefaults.swift
//  BarcodeApp
//
//  Created by mac-089-71 on 10/30/18.
//  Copyright © 2018 VPavelDm. All rights reserved.
//

import Foundation

extension UserDefaults {
    
    func addCachedUrl(url: URL) -> String {
        var dictionary = self.dictionary(forKey: "cachedUrls") as? Dictionary<String, String> ?? [:]
        let name = getNextCachedName()
        dictionary[url.absoluteString] = name
        set(dictionary, forKey: "cachedUrls")
        return name
    }
    
    func getCachedUrls() -> [URL] {
        syncCachedURL()
        let dictionary = self.dictionary(forKey: "cachedUrls") as? Dictionary<String, String> ?? [:]
        return dictionary.keys.map { URL(string: $0)! }
    }
    
    func getLocalUrl(for url: URL) -> URL? {
        var dictionary = self.dictionary(forKey: "cachedUrls") as? Dictionary<String, String> ?? [:]
        if let name = dictionary[url.absoluteString] {
            do {
                let cachesDirectory = try FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                return cachesDirectory.appendingPathComponent(name)
            } catch _ {}
        }
        return nil
    }
    
    private func syncCachedURL() {
        do {
            var dictionary = self.dictionary(forKey: "cachedUrls") as? Dictionary<String, String> ?? [:]
            let cachesDirectory = try FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            var contents = try FileManager.default.contentsOfDirectory(atPath: cachesDirectory.path)
            contents = contents.filter { $0.starts(with: "com_vpaveldm_")}
            dictionary = dictionary.filter { contents.contains($0.value)}
            set(dictionary, forKey: "cachedUrls")
        } catch _ {}
    }
    
    private func getNextCachedName() -> String {
        return "com_vpaveldm_" + String(dictionary(forKey: "cachedUrls")?.count ?? 0)
    }
    
}
