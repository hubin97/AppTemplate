//
//  TestListController.swift
//  HBSwiftKit_Example
//
//  Created by hubin.h on 2024/12/27.

import Foundation
import AppStart
import Router
// MARK: - global var and methods

// MARK: - main class
class TestListController: ViewController {
    
    let items = ["Safari", "SafariController"]
    
    lazy var tableView: UITableView = {
        let _tableView = UITableView(frame: .zero, style: .plain)
        _tableView.backgroundColor = .white
        _tableView.registerCell(TableViewCell.self)
        _tableView.dataSource = self
        _tableView.delegate = self
        _tableView.rowHeight = 50
        return _tableView
    }()
    
    override func setupLayout() {
        super.setupLayout()
        self.naviBar.title = L10n.stringDemoList
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(naviBar.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    override func bindViewModel() {
        super.bindViewModel()
    }
}

// MARK: - private mothods
extension TestListController { 
}

// MARK: - call backs
extension TestListController { 
}

// MARK: - delegate or data source
extension TestListController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.getReusableCell(TableViewCell.self)
        cell.textLabel?.text = items[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath.row {
        case 0:
            navigator.show(provider: BaseScene.safari(URL(string: "https://www.baidu.com")!), sender: self)
        case 1:
            navigator.show(provider: BaseScene.safariController(URL(string: "https://www.baidu.com")!), sender: self, transition: .alert(type: .fullScreen))
        default:
            break
        }
    }
}

// MARK: - other classes
