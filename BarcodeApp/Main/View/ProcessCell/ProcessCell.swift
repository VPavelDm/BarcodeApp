//
//  ProcessCell.swift
//  BarcodeApp
//
//  Created by mac-089-71 on 10/24/18.
//  Copyright © 2018 VPavelDm. All rights reserved.
//

import UIKit

class ProcessCell: UITableViewCell {

    @IBOutlet private weak var urlLabel: UILabel!
    
    @IBAction private func clickProcess(_ sender: Any) {
        
    }
    
    func initCell(url: URL) {
        urlLabel.text = url.absoluteString
    }
    
}
