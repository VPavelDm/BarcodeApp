//
//  BarcodeDescriptionViewController.swift
//  BarcodeApp
//
//  Created by mac-089-71 on 11/5/18.
//  Copyright © 2018 VPavelDm. All rights reserved.
//

import UIKit

class BarcodeDescriptionViewController: UIViewController {

    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var image: UIImageView! {
        didSet {
            let data = fileManager.readImage(with: url)
            image.image = (data == nil) ? UIImage(named: "default") : UIImage(data: data!)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    var url: URL!
    
    private let fileManager = ImageFileManager()

}

extension BarcodeDescriptionViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DetailCell", for: indexPath)
        
        return cell
    }
    
}
