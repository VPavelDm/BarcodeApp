//
//  BarcodeDescriptionViewController.swift
//  BarcodeApp
//
//  Created by mac-089-71 on 11/5/18.
//  Copyright © 2018 VPavelDm. All rights reserved.
//

import UIKit
import RxSwift

class BarcodeDescriptionViewController: UIViewController {

    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var image: UIImageView! {
        didSet {
            if let imageData = URLCache.instance.readItem(loadedFrom: url) {
                image.image = UIImage(data: imageData)
            } else {
                image.image = UIImage(named: "default")
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        registerCells()
        loadBarcodes()
    }
    
    private func registerCells() {
        tableView.register(UINib(nibName: DetailCell.identifier, bundle: nil), forCellReuseIdentifier: DetailCell.identifier)        
    }
    private func loadBarcodes() {
        viewModel.loadBarcodes(for: url)
            .observeOn(MainScheduler.instance)
            .subscribeOn(ConcurrentDispatchQueueScheduler.init(qos: .userInitiated))
            .subscribe(onCompleted: { [weak self] in
                self?.tableView.reloadData()
            }).disposed(by: disposeBag)
    }
    
    var url: URL!
    private let viewModel = BarcodeDescriptionViewModel()
    private let disposeBag = DisposeBag()
    
}

extension BarcodeDescriptionViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.barcodes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DetailCell.identifier, for: indexPath) as! DetailCell
        
        cell.initCell(count: indexPath.row)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let drawService = ImageDrawService()
        let barcode = viewModel.barcodes[indexPath.row]
        image.image = drawService.draw(on: image.image!,
                         leftTopCorner: (x: barcode.x1, y: barcode.y1),
                         rightBottomCorner: (x: barcode.x2, y: barcode.y2))
    }
    
}
