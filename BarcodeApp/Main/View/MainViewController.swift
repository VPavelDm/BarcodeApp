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
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadImages()
    }
    
    private var cellStates: [Int:CellState] = [:]
    private let viewModel = MainViewModel()
    private let disposeBag = DisposeBag()
    
    private func registerCells() {
        tableView.register(UINib(nibName: DownloadCell.identifier, bundle: nil), forCellReuseIdentifier: DownloadCell.identifier)
        tableView.register(UINib(nibName: ProcessCell.identifier, bundle: nil), forCellReuseIdentifier: ProcessCell.identifier)
        tableView.register(UINib(nibName: ResultCell.identifier, bundle: nil), forCellReuseIdentifier: ResultCell.identifier)
    }
    
    private func loadImages() {
        func updateCell(indexes: Event<[Int]>) {
            guard let _ = indexes.element else { return }
            tableView.reloadData()
        }
        let notLoadedObservable = viewModel.notLoadedObservable.do(onNext: { [weak self] in self?.cellStates[$0] = .notLoaded })
        let loadedObservable = viewModel.loadedObservable.do(onNext: { [weak self] in self?.cellStates[$0] = .loaded })
        let processedObservable = viewModel.processedObservable.do(onNext: { [weak self] in self?.cellStates[$0] = .processed })
        
        Observable
            .concat(notLoadedObservable, loadedObservable, processedObservable)
            .filter{ $0 >= 0 }
            .toArray()
            .subscribe(updateCell)
        .disposed(by: disposeBag)
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
