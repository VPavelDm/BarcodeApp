//
//  DetailCell.swift
//  BarcodeApp
//
//  Created by mac-089-71 on 11/5/18.
//  Copyright © 2018 VPavelDm. All rights reserved.
//

import UIKit

class DetailCell: UITableViewCell {

    @IBOutlet private weak var barcodePositionLabel: UILabel!
    
    func initCell(count: Int) {
        barcodePositionLabel.text = String(count)
    }
    
}
