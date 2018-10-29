//
//  DownloadCell.swift
//  BarcodeApp
//
//  Created by mac-089-71 on 10/24/18.
//  Copyright © 2018 VPavelDm. All rights reserved.
//

import UIKit

class DownloadCell: UITableViewCell {

    @IBOutlet private weak var urlLabel: UILabel!
    
    @IBAction private func clickDownload(_ sender: Any) {
        delegate?.downloadButtonIsClicked(cell: self)
    }
    
    weak var delegate: DownloadCellDelegate?
    
    var url: String {
        return urlLabel.text!
    }
    
    func initCell(url: String) {
        urlLabel.text = url
    }
    
}

protocol DownloadCellDelegate: class {
    func downloadButtonIsClicked(cell: DownloadCell)
}
