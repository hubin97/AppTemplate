//
//  ViewController.swift
//  HBSwiftKitExample
//
//  Created by design on 2020/11/2.
//

import UIKit
import Router
import Demo
//import GDPerformanceView_Swift

// MARK: - main class
class ListViewController: ViewController, ViewModelProvider {
    typealias ViewModelType = ListViewModel
    
    lazy var listView: UITableView = {
        let listView = UITableView(frame: CGRect.zero, style: .plain)
        listView.backgroundColor = .white
        listView.register(UITableViewCell.self, forCellReuseIdentifier: NSStringFromClass(UITableViewCell.self))
        listView.tableFooterView = UIView.init(frame: CGRect.zero)
        listView.dataSource = self
        listView.delegate = self
        listView.rowHeight = 50
        return listView
    }()

    override func setupLayout() {
        super.setupLayout()
        view.addSubview(listView)
        naviBar.title = "Example List"
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

// MARK: - delegate or data source
extension ListViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vm.items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = vm.items[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(UITableViewCell.self), for: indexPath)
        cell.contentView.backgroundColor = .white
        cell.textLabel?.text = model.title
        cell.textLabel?.textColor = .black
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = vm.items[indexPath.row]
        switch item {
        case .test:
            let path = "https://iot-dev.luteos.com/app/pageActivityManagement/void" + "?openSource=App"
            navigator.show(provider: AppScene.jsWeb(path: path, title: nil, symbol: "LUTE_NATIVE"), sender: self)
        case .mediaList:
            //navigator.show(provider: AppScene.mediaList, sender: self)
            //iToast.makeToast(">> mediaList")
            let url = "https://cozy-static-dev.cozyinnov.com/public/970040/%E7%AC%AC%E4%BA%8C%E6%AC%A1%E4%B8%93%E5%AE%B6%E7%9B%B4%E6%92%AD%E5%BD%95%E5%B1%8F25.8.19.mp4"
            navigator.show(provider: AppScene.videoPlayController(url: url, autoPlay: true, isWrap: true), sender: self, transition: .alert(type: .fullScreen))
        case .routeTest:
            navigator.show(provider: RouteScene.testList, sender: self)
        case .demoTest:
            navigator.show(provider: DemoScene.testList, sender: self)
        case .imageDecoder:
            navigator.show(provider: AppScene.imageDecoder, sender: self)
        }
    }
}
