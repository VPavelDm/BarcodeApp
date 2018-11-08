//
//  FileManager.swift
//  BarcodeApp
//
//  Created by mac-089-71 on 11/8/18.
//  Copyright © 2018 VPavelDm. All rights reserved.
//

import Foundation

extension FileManager {
    
    func moveItemLoadedFromNetwork(location: URL, networkURL url: URL) throws {
        let localURL = localFileURL(forNetworkURL: url)
        try? removeItem(at: localURL)
        do {
            try copyItem(at: location, to: localURL)
        } catch let error {
            throw error
        }
    }
    
    func readItemLoadedFromNetwork(networkURL url: URL) -> Data? {
        let localURL = localFileURL(forNetworkURL: url)
        return contents(atPath: localURL.path)
    }
    
    private func localFileURL(forNetworkURL networkURL: URL) -> URL {
        let documentPath = try! url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        return documentPath.appendingPathComponent(networkURL.lastPathComponent)
    }
    
}
