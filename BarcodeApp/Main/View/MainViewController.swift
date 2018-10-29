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
    
    private var urlsWithState: [CellState] = []
    private let viewModel = MainViewModel()
    private let disposeBag = DisposeBag()
    
    private func registerCells() {
        tableView.register(UINib(nibName: DownloadCell.identifier, bundle: nil), forCellReuseIdentifier: DownloadCell.identifier)
        tableView.register(UINib(nibName: ProcessCell.identifier, bundle: nil), forCellReuseIdentifier: ProcessCell.identifier)
        tableView.register(UINib(nibName: ResultCell.identifier, bundle: nil), forCellReuseIdentifier: ResultCell.identifier)
    }
    
    private func loadImages() {
        let notLoadedObservable = viewModel.notLoadedObservable
            .do(onNext: { [weak self] in self?.urlsWithState.append(.notLoaded($0))})
        let loadedObservable = viewModel.loadedObservable
            .do(onNext: { [weak self] in self?.urlsWithState.append(.loaded($0))})
        let processedObservable = viewModel.processedObservable
            .do(onNext: { [weak self] in self?.urlsWithState.append(.processed($0.barcodeCount)) })
            .map{ $0.url }
        
        Observable
            .concat(notLoadedObservable, loadedObservable, processedObservable)
            .do(onDispose: { [weak self] in self?.tableView.reloadData() })
            .subscribe()
        .disposed(by: disposeBag)
    }

}

enum CellState {
    case notLoaded(URL)
    case loaded(URL)
    case processed(Int)
}

extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return urlsWithState.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let index = indexPath.row
        switch urlsWithState[index] {
        case .notLoaded(let url):
            let cell = tableView.dequeueReusableCell(withIdentifier: DownloadCell.identifier, for: indexPath) as! DownloadCell
            cell.initCell(url: url.absoluteString)
            return cell
        case .loaded(let url):
            let cell = tableView.dequeueReusableCell(withIdentifier: ProcessCell.identifier, for: indexPath) as! ProcessCell
            cell.initCell(url: url.absoluteString)
            return cell
        case .processed(let count):
            let cell = tableView.dequeueReusableCell(withIdentifier: ResultCell.identifier, for: indexPath) as! ResultCell
            cell.initCell(barcodeCount: count)
            return cell
        }
    }
}
