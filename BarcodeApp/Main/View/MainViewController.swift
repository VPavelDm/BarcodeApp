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
        loadImages()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    private let viewModel = MainViewModel()
    private let disposeBag = DisposeBag()
    
    private func registerCells() {
        tableView.register(UINib(nibName: DownloadCell.identifier, bundle: nil), forCellReuseIdentifier: DownloadCell.identifier)
        tableView.register(UINib(nibName: ProcessCell.identifier, bundle: nil), forCellReuseIdentifier: ProcessCell.identifier)
        tableView.register(UINib(nibName: ResultCell.identifier, bundle: nil), forCellReuseIdentifier: ResultCell.identifier)
    }
    
    private func loadImages() {
        viewModel.dataObservable
            .subscribe { [unowned self] _ in
                self.tableView.delegate = self
                self.tableView.dataSource = self
                self.tableView.reloadData()
            }
            .disposed(by: disposeBag)
    }

}

extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.cells.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = viewModel.cells[indexPath.row]
        switch cell {
        case .notLoaded(let url):
            let cell = tableView.dequeueReusableCell(withIdentifier: DownloadCell.identifier, for: indexPath) as! DownloadCell
            cell.delegate = self
            cell.initCell(url: url)
            return cell
        case .loaded(let url):
            let cell = tableView.dequeueReusableCell(withIdentifier: ProcessCell.identifier, for: indexPath) as! ProcessCell
            cell.initCell(url: url)
            return cell
        case .processed(let count):
            let cell = tableView.dequeueReusableCell(withIdentifier: ResultCell.identifier, for: indexPath) as! ResultCell
            cell.initCell(barcodeCount: count)
            return cell
        }
    }
}

extension MainViewController: DownloadCellDelegate {
    func downloadButtonIsClicked(cell: DownloadCell) {
        viewModel.loadImage(with: cell.url)
            .subscribe(onSuccess: { [weak self] (indexes) in
                let indexesPath = indexes.map { IndexPath(row: $0, section: 0) }
                self?.tableView.reloadRows(at: indexesPath, with: .automatic)
            }, onError: { (error) in
                print(error.localizedDescription)
            })
            .disposed(by: disposeBag)
    }    
    
}
