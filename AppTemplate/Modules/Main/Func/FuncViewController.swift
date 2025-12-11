//
//  FuncViewController.swift
//  AppTemplate
//
//  Created by hubin.h on 2025/12/10.
//  Copyright © 2025 hubin.h. All rights reserved.

import Foundation
import Router
import Demo

// MARK: - Global Variables & Functions (if necessary)

// MARK: - Main Class
class FuncViewController: ViewController, ViewModelProvider {
    typealias ViewModelType = FuncViewModel
  
    lazy var listView: TableView = {
        let listView = TableView(frame: CGRect.zero, style: .plain)
        listView.backgroundColor = .white
        listView.registerCell(TableViewCell.self)
        listView.tableFooterView = UIView(frame: CGRect.zero)
        listView.dataSource = self
        listView.delegate = self
        listView.rowHeight = 50
        return listView
    }()
 
    override func setupLayout() {
        super.setupLayout()
        view.addSubview(listView)
        naviBar.title = "Functions"
        naviBar.leftView?.isHidden = true
        
        listView.snp.makeConstraints { (make) in
            make.top.equalTo(naviBar.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //PerformanceMonitor.shared().start()
        listView.backgroundColor = SFColor.FlatUI.clouds
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("viewWillDisappear-")
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) {
            return .darkContent
        } else {
            return .default
        }
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .allButUpsideDown
    }
}

// MARK: - Private Methods
extension FuncViewController {
}

// MARK: - Callbacks
extension FuncViewController {
}

// MARK: - Utilities & Helpers
extension FuncViewController {
}

// MARK: - Delegate & Data Source
extension FuncViewController: UITableViewDataSource, UITableViewDelegate {
    
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
        case .jsTest:
            navigator.show(provider: AppScene.jsTest, sender: self)
        case .webP:
            navigator.show(provider: AppScene.imageDecoder, sender: self)
        case .route:
            navigator.show(provider: RouteScene.testList, sender: self)
        case .safari:
            navigator.show(provider: DemoScene.testList, sender: self)
        case .AVPlayerViewController:
            let url = "https://cozy-static-dev.cozyinnov.com/public/970040/C00000001/app/feedback/67877d72e4b0604661da588b.mp4"
            navigator.show(provider: BaseScene.videoPlayController(url: url, autoPlay: true, isWrap: true), sender: self, transition: .modal(type: .fullScreen))
        }
    }
}
