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
    @IBOutlet weak var progressView: UIProgressView!
    
    @IBAction private func clickDownload(_ sender: Any) {
        delegate?.downloadButtonIsClicked(cell: self)
    }
    
    weak var delegate: DownloadCellDelegate?
    
    var url: URL? {
        if let text = urlLabel.text {
            return URL(string: text)!
        } else {
            return nil
        }
    }
    var indexPath: IndexPath?
    
    func initCell(url: URL, progress: Float, indexPath: IndexPath) {
        urlLabel.text = url.absoluteString
        progressView.progress = progress
        self.indexPath = indexPath
    }
    
}

protocol DownloadCellDelegate: class {
    func downloadButtonIsClicked(cell: DownloadCell)
}
