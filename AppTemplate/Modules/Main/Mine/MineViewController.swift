//
//  MineViewController.swift
//  AppTemplate
//
//  Created by hubin.h on 2025/12/10.
//  Copyright © 2025 hubin.h. All rights reserved.

import Foundation
import Kingfisher
// MARK: - Global Variables & Functions (if necessary)

// MARK: - Main Class
class MineViewController: DefaultViewController, ViewModelProvider {
    typealias ViewModelType = MineViewModel
    
    let languageChanged = BehaviorRelay<Void>(value: ())

    lazy var tableView: TableView = {
        let listView = TableView(frame: CGRect.zero, style: .plain)
        listView.backgroundColor = .white
        listView.registerCell(SettingSwitchCell.self)
        listView.tableFooterView = UIView(frame: CGRect.zero)
        listView.dataSource = self
        listView.delegate = self
        listView.rowHeight = 50
        listView.mj_header = RefreshHeader(refreshingBlock: {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                listView.mj_header?.endRefreshing()
            }
        })
        return listView
    }()

    override func setupLayout() {
        super.setupLayout()
        view.addSubview(tableView)
        naviBar.title = "Profile"
        naviBar.leftView?.isHidden = true
        
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(naviBar.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    override func bindViewModel() {
        super.bindViewModel()
        withThemeUpdates { (self, theme) in
            print("MineViewController-withThemeUpdates")
//            self.view.backgroundColor = theme.backgroundColor
//            self.naviBar.backgroundColor = theme.backgroundColor
            self.tableView.backgroundColor = theme.tableViewColor
//            self.naviBar.textColor = theme.textColor
        }
        
        let refresh = Observable.of(rx.viewWillAppear.mapToVoid(), languageChanged.asObservable()).merge()
        refresh.bind(to: vm.refresh).disposed(by: rx.disposeBag)       
    }
}

// MARK: - Private Methods
extension MineViewController {
}

// MARK: - Callbacks
extension MineViewController {
}

// MARK: - Utilities & Helpers
extension MineViewController {
}

// MARK: - Delegate & Data Source
extension MineViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vm.items.value.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = vm.items.value[indexPath.row]
        let cell = tableView.getReusableCell(SettingSwitchCell.self)
        cell.bind(to: item)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
