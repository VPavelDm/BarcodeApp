//
//  MainViewController.swift
//  BarcodeApp
//
//  Created by mac-089-71 on 10/24/18.
//  Copyright © 2018 VPavelDm. All rights reserved.
//

import UIKit
import RxSwift
import Firebase

class MainViewController: UIViewController {
    
    @IBOutlet private weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerCells()
        loadImages()
    }
    
    private let viewModel = MainViewModel()
    private let disposeBag = DisposeBag()
    
    private func registerCells() {
        tableView.register(UINib(nibName: DownloadCell.identifier, bundle: nil), forCellReuseIdentifier: DownloadCell.identifier)
        tableView.register(UINib(nibName: ProcessCell.identifier, bundle: nil), forCellReuseIdentifier: ProcessCell.identifier)
        tableView.register(UINib(nibName: ResultCell.identifier, bundle: nil), forCellReuseIdentifier: ResultCell.identifier)
    }
    
    private func loadImages() {
        viewModel.getData()
            .observeOn(MainScheduler.instance)
            .subscribeOn(ConcurrentDispatchQueueScheduler.init(qos: .userInitiated))
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
            cell.initCell(url: url, progress: viewModel.getProgress(for: url), indexPath: indexPath)
            return cell
        case .loaded(let url):
            let cell = tableView.dequeueReusableCell(withIdentifier: ProcessCell.identifier, for: indexPath) as! ProcessCell
            cell.delegate = self
            cell.initCell(url: url, indexPath: indexPath)
            return cell
        case .processed(let url, let count):
            let cell = tableView.dequeueReusableCell(withIdentifier: ResultCell.identifier, for: indexPath) as! ResultCell
            cell.delegate = self
            cell.initCell(url: url, barcodeCount: count)
            return cell
        }
    }
}

extension MainViewController: DownloadCellDelegate, ProcessCellDelegate, ResultCellDelegate {
    func showResultButtonIsClicked(cell: ResultCell) {
        let barcodeDescriptionViewController = BarcodeDescriptionViewController.createViewController(asClass: BarcodeDescriptionViewController.self)
        barcodeDescriptionViewController.url = cell.url
        navigationController?.pushViewController(barcodeDescriptionViewController, animated: true)
    }
    
    func processButtonIsClicked(cell: ProcessCell) {
        guard let url = cell.url else { return }
        viewModel.findBarcodes(url: url)
            .observeOn(MainScheduler.instance)
            .subscribeOn(ConcurrentDispatchQueueScheduler.init(qos: .userInitiated))
            .subscribe(onCompleted: { [weak self] in
                guard let `self` = self, let indexPath = cell.indexPath else { return }
                self.tableView.reloadRows(at: [indexPath], with: .automatic)
            }, onError: { [weak self] (error) in
                guard let `self` = self else { return }
                let alert = UIAlertController(with: error)
                self.present(alert, animated: true)
            }).disposed(by: disposeBag)
    }
    
    func downloadButtonIsClicked(cell: DownloadCell) {
        assert(cell.url != nil && cell.indexPath != nil, "The Cell is not initialized")
        guard let url = cell.url, let indexPath = cell.indexPath else { return }
        viewModel.loadImage(url: url)
            .observeOn(MainScheduler.instance)
            .subscribeOn(ConcurrentDispatchQueueScheduler.init(qos: .userInitiated))
            .subscribe(onNext: { [weak self] (progress) in
                guard let `self` = self, let cell = self.tableView.cellForRow(at: indexPath) as? DownloadCell else { return }
                cell.progressView.progress = progress
            }, onError: { [weak self] (error) in
                guard let `self` = self else { return }
                let alert = UIAlertController(with: error)
                self.present(alert, animated: true)
            }, onCompleted: { [weak self] in
                guard let `self` = self, let indexPath = cell.indexPath else { return }
                self.tableView.reloadRows(at: [indexPath], with: .automatic)
            })
            .disposed(by: disposeBag)
    }
    
}
