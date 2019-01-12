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
        delegate?.processButtonIsClicked(cell: self)
    }
    
    var url: URL? {
        if let text = urlLabel.text {
            return URL(string: text)!
        } else {
            return nil
        }
    }
    var indexPath: IndexPath?
    weak var delegate: ProcessCellDelegate?
    
    func initCell(url: URL, indexPath: IndexPath) {
        urlLabel.text = url.absoluteString
        self.indexPath = indexPath
    }
    
}

protocol ProcessCellDelegate: class {
    func processButtonIsClicked(cell: ProcessCell)
}
