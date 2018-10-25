//
//  MainViewController.swift
//  BarcodeApp
//
//  Created by mac-089-71 on 10/24/18.
//  Copyright © 2018 VPavelDm. All rights reserved.
//

import UIKit
import RxSwift

class MainViewController: UIViewController {
    
    @IBOutlet private weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        registerCells()
        subscribeOnImageUpdate()
    }
    
    private var cellStates: [Int:CellState] = [:]
    private let viewModel = MainViewModel()
    private let disposedBag = DisposeBag()
    
    private func registerCells() {
        tableView.register(UINib(nibName: DownloadCell.identifier, bundle: nil), forCellReuseIdentifier: DownloadCell.identifier)
        tableView.register(UINib(nibName: ProcessCell.identifier, bundle: nil), forCellReuseIdentifier: ProcessCell.identifier)
        tableView.register(UINib(nibName: ResultCell.identifier, bundle: nil), forCellReuseIdentifier: ResultCell.identifier)
    }
    
    private func subscribeOnImageUpdate() {
        viewModel.notLoadedObservable.subscribe { [weak self] index in
            guard let `self` = self, let index = index.element else { return }
            updateCell(by: index, with: .notLoaded)
            }.disposed(by: disposedBag)
        
        viewModel.loadedObservable.subscribe { [weak self] index in
            guard let `self` = self, let index = index.element else { return }
            updateCell(by: index, with: .loaded)
            }.disposed(by: disposedBag)
        
        viewModel.processedObservable.subscribe { [weak self] index in
            guard let `self` = self, let index = index.element else { return }
            updateCell(by: index, with: .processed)
            }.disposed(by: disposedBag)
        
        func updateCell(by index: Int, with state: CellState) {
            let indexPath = IndexPath(row: index, section: 0)
            if let _ = cellStates[index] {
                cellStates[index] = state
                tableView.reloadRows(at: [indexPath], with: .automatic)
            } else {
                cellStates[index] = state
                tableView.insertRows(at: [indexPath], with: .automatic)
            }
        }
    }

}

enum CellState {
    case notLoaded
    case loaded
    case processed
}

extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellStates.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let index = indexPath.row
        switch cellStates[index]! {
        case .notLoaded:
            let cell = tableView.dequeueReusableCell(withIdentifier: DownloadCell.identifier, for: indexPath) as! DownloadCell
            cell.initCell(url: viewModel.images[indexPath.row].url.absoluteString)
            return cell
        case .loaded:
            let cell = tableView.dequeueReusableCell(withIdentifier: ProcessCell.identifier, for: indexPath) as! ProcessCell
            cell.initCell(url: viewModel.images[indexPath.row].url.absoluteString)
            return cell
        case .processed:
            let cell = tableView.dequeueReusableCell(withIdentifier: ResultCell.identifier, for: indexPath) as! ResultCell
            cell.initCell(barcodeCount: viewModel.images[indexPath.row].barcodes.count)
            return cell
        }
    }
}
