//
//  UserDefaults.swift
//  BarcodeApp
//
//  Created by mac-089-71 on 10/30/18.
//  Copyright © 2018 VPavelDm. All rights reserved.
//

import Foundation

extension UserDefaults {
    
    func addNetworkURL(url: URL) -> String {
        var dictionary = self.dictionary(forKey: "cachedUrls") as? Dictionary<String, String> ?? [:]
        let name = getNextCachedName()
        dictionary[url.absoluteString] = name
        set(dictionary, forKey: "cachedUrls")
        return name
    }
    
    func getNetworkURLs() -> [URL] {
        syncCachedURL()
        let dictionary = self.dictionary(forKey: "cachedUrls") as? Dictionary<String, String> ?? [:]
        return dictionary.keys.map { URL(string: $0)! }
    }
    
    func getLocalUrl(for networkURL: URL) -> URL? {
        guard
            let cachesDirectory = try? FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: false),
            let dictionary = self.dictionary(forKey: "cachedUrls") as? Dictionary<String, String>,
            let name = dictionary[networkURL.absoluteString]
            else { return nil }
        return cachesDirectory.appendingPathComponent(name)
    }
    
    private func syncCachedURL() {
        guard
            let cachesDirectory = try? FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: false),
            var dictionary = self.dictionary(forKey: "cachedUrls") as? Dictionary<String, String>,
            var contents = try? FileManager.default.contentsOfDirectory(atPath: cachesDirectory.path)
            else { return }
        contents = contents.filter { $0.starts(with: "com_vpaveldm_")}
        dictionary = dictionary.filter { contents.contains($0.value)}
        set(dictionary, forKey: "cachedUrls")
    }
    
    private func getNextCachedName() -> String {
        return "com_vpaveldm_" + String(dictionary(forKey: "cachedUrls")?.count ?? 0)
    }
    
}
