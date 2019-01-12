//
//  SettingsBundleHelper.swift
//  BarcodeApp
//
//  Created by mac-089-71 on 11/12/18.
//  Copyright © 2018 VPavelDm. All rights reserved.
//

import Foundation

class SettingsBundleHelper {
    
    init() {
        UserDefaults.standard.register(defaults: ["barcodeFinderSetting" : MLType.MLKit.rawValue])
    }
    
    struct SettingsKey {
        static let MLType = "barcodeFinderSetting"
    }
    
    func resetData() {
        
    }
    
    func getMLType() -> MLType {
        let type = UserDefaults.standard.string(forKey: SettingsKey.MLType) ?? MLType.MLKit.rawValue
        return MLType(rawValue: type) ?? MLType.MLKit
    }
    
}

enum MLType: String {
    case MLKit
    case CoreML
}
