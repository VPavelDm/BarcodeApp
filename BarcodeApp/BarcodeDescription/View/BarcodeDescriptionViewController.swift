//
//  BarcodeDescriptionViewController.swift
//  BarcodeApp
//
//  Created by mac-089-71 on 11/5/18.
//  Copyright © 2018 VPavelDm. All rights reserved.
//

import UIKit

class BarcodeDescriptionViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }

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
