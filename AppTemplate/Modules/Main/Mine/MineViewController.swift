//
//  MineViewController.swift
//  AppTemplate
//
//  Created by hubin.h on 2025/12/10.
//  Copyright © 2025 hubin.h. All rights reserved.

import Foundation

// MARK: - Global Variables & Functions (if necessary)

// MARK: - Main Class
class MineViewController: ViewController, ViewModelProvider {
    typealias ViewModelType = MineViewModel
    
    lazy var listView: TableView = {
        let listView = TableView(frame: CGRect.zero, style: .plain)
        listView.backgroundColor = .white
        listView.registerCell(TableViewCell.self)
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
        view.addSubview(listView)
        naviBar.title = "Profile"
        naviBar.leftView?.isHidden = true
        
        listView.snp.makeConstraints { (make) in
            make.top.equalTo(naviBar.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
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
        return vm.items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = vm.items[indexPath.row]
        let cell = tableView.getReusableCell(TableViewCell.self)
        cell.textLabel?.text = item.rawValue
        cell.textLabel?.textColor = .black
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = vm.items[indexPath.row]
        switch item {
        case .nightMode:
            break
        case .themeMode:
            break
        }
    }
}
