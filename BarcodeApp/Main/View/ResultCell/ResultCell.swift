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
    @IBOutlet private weak var urlLabel: UILabel!
    
    @IBAction private func clickShowResult(_ sender: Any) {
        delegate?.showResultButtonIsClicked(cell: self)
    }
    
    var url: URL? {
        if let text = urlLabel.text {
            return URL(string: text)!
        } else {
            return nil
        }
    }
    weak var delegate: ResultCellDelegate?
    
    func initCell(url: URL, barcodeCount: Int) {
        barcodeCountLabel.text = String(barcodeCount)
        urlLabel.text = url.absoluteString
    }
    
}

protocol ResultCellDelegate: class {
    func showResultButtonIsClicked(cell: ResultCell)
}
