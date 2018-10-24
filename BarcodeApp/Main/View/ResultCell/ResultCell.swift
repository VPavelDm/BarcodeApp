//
//  ResultCell.swift
//  BarcodeApp
//
//  Created by mac-089-71 on 10/24/18.
//  Copyright © 2018 VPavelDm. All rights reserved.
//

import UIKit

class ResultCell: UITableViewCell {

    @IBOutlet private weak var barcodeCountLabel: UILabel!
    
    @IBAction private func clickShowResult(_ sender: Any) {
        
    }
    
    func initCell(barcodeCount: String) {
        barcodeCountLabel.text = barcodeCount
    }
    
}
