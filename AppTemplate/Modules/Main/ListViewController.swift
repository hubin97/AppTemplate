//
//  ViewController.swift
//  HBSwiftKitExample
//
//  Created by design on 2020/11/2.
//

import UIKit
import AppStart
import Router
import Demo
import MJRefresh
//import GDPerformanceView_Swift

// MARK: - main class
class ListViewController: ViewController, ViewModelProvider {
    typealias ViewModelType = ListViewModel
    
    lazy var listView: TableView = {
        let listView = TableView(frame: CGRect.zero, style: .plain)
        listView.backgroundColor = .white
        listView.registerCell(TableViewCell.self)
        listView.tableFooterView = UIView.init(frame: CGRect.zero)
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
        let cell = tableView.getReusableCell(TableViewCell.self)
        cell.textLabel?.text = model.title
        cell.textLabel?.textColor = .black
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = vm.items[indexPath.row]
        switch item {
        case .test:
//            let path = "https://iot-dev.luteos.com/app/pageActivityManagement/void" + "?openSource=App"
//            navigator.show(provider: BaseScene.webController(path: path, title: nil, symbol: "LUTE_NATIVE"), sender: self)
            alertTest()
        case .mediaList:
            let url = "https://cozy-static-dev.cozyinnov.com/public/970040/C00000001/app/feedback/67877d72e4b0604661da588b.mp4"
            navigator.show(provider: BaseScene.videoPlayController(url: url, autoPlay: true, isWrap: true), sender: self, transition: .modal(type: .fullScreen))
        case .routeTest:
            navigator.show(provider: RouteScene.testList, sender: self)
        case .demoTest:
            navigator.show(provider: DemoScene.testList, sender: self)
        case .imageDecoder:
            navigator.show(provider: AppScene.imageDecoder, sender: self)
        }
    }
}

extension ListViewController {
    
    func alertTest() {
        
//        // 1️⃣ 普通弹窗
//        let normalAlert = PriorityBaseAlertView(priority: .normal, icon: nil, title: "普通", message: "普通消息")
//        normalAlert.onStateChange = { state in
//            print("NormalAlert state: \(state)")
//        }
//        normalAlert.addPrimaryAction(title: "确认") {
//            print("NormalAlert primary tapped")
//        }
//        
//        // 2️⃣ 更高优先级弹窗
//        let higherAlert = PriorityBaseAlertView(priority: .higher, icon: nil, title: "更高", message: "高优先级消息")
//        higherAlert.onStateChange = { state in
//            print("HigherAlert state: \(state)")
//        }
//        higherAlert.addPrimaryAction(title: "确认") {
//            print("HigherAlert primary tapped")
//        }
//
//        // 3️⃣ 强制弹窗
//        let forceAlert = PriorityBaseAlertView(priority: .force, icon: nil, title: "强制", message: "强制打断消息")
//        forceAlert.onStateChange = { state in
//            print("ForceAlert state: \(state)")
//        }
//        forceAlert.addPrimaryAction(title: "确认") {
//            print("forceAlert primary tapped")
//        }
//
//        // 4️⃣ 依次展示
//        normalAlert.show()
//        
//        // 模拟稍后更高优先级弹窗入队
//        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
//            higherAlert.show()
//        }
//        
//        // 模拟稍后强制弹窗入队
//        DispatchQueue.main.asyncAfter(deadline: .now() + 6) {
//            forceAlert.show()
//        }
        
        Array(0...3).forEach { idx in
            self.normalAlert(with: idx)
        }
        
        // 模拟稍后较高优先级弹窗入队
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            Array(0...3).forEach { idx in
                self.highAlert(with: idx)
            }
        }
        
        // 模拟稍后更高优先级弹窗入队
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            Array(0...3).forEach { idx in
                self.higherAlert(with: idx)
            }
        }
        
        // 强制的
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            Array(0...3).forEach { idx in
                self.forceAlert(with: idx)
            }
        }
        
        // 致命的
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            Array(0...3).forEach { idx in
                self.fatalAlert(with: idx)
            }
        }
        
        // 强制的
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            Array(0...3).forEach { idx in
                self.forceAlert(with: idx)
            }
        }
        
        // 模拟稍后更高优先级弹窗入队
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            Array(0...3).forEach { idx in
                self.higherAlert(with: idx)
            }
        }
        
        // 强制的
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            Array(0...3).forEach { idx in
                self.forceAlert(with: idx)
            }
        }
    }
    
    func normalAlert(with idx: Int) {
        let normalAlert = PriorityBaseAlertView(priority: .normal, icon: nil, title: "普通: \(idx)", message: "普通消息")
        normalAlert.onStateChange = { state in
            print("NormalAlert state: \(state)")
        }
        normalAlert.addPrimaryAction(title: "确认") {
            print("NormalAlert primary tapped")
        }
        normalAlert.show()
    }
    
    func highAlert(with idx: Int) {
        let highAlert = PriorityBaseAlertView(priority: .high, icon: nil, title: "较高: \(idx)", message: "高优先级消息")
        highAlert.onStateChange = { state in
            print("highAlert state: \(state)")
        }
        highAlert.addPrimaryAction(title: "确认") {
            print("highAlert primary tapped")
        }
        highAlert.show()
    }
    
    func higherAlert(with idx: Int) {
        let higherAlert = PriorityBaseAlertView(priority: .higher, icon: nil, title: "更高: \(idx)", message: "更高优先级消息")
        higherAlert.onStateChange = { state in
            print("HigherAlert state: \(state)")
        }
        higherAlert.addPrimaryAction(title: "确认") {
            print("HigherAlert primary tapped")
        }
        higherAlert.show()
    }
    
    func forceAlert(with idx: Int) {
        let forceAlert = PriorityBaseAlertView(priority: .force, icon: nil, title: "强制: \(idx)", message: "强制打断消息")
        forceAlert.onStateChange = { state in
            print("ForceAlert state: \(state)")
        }
        forceAlert.addPrimaryAction(title: "确认") {
            print("forceAlert primary tapped")
        }
        forceAlert.show()
    }
    
    func fatalAlert(with idx: Int) {
        let fatalAlert = PriorityBaseAlertView(priority: .fatal, icon: nil, title: "致命: \(idx)", message: "致命的消息")
        fatalAlert.onStateChange = { state in
            print("fatalAlert state: \(state)")
        }
        fatalAlert.addPrimaryAction(title: "确认") {
            print("fatalAlert primary tapped")
        }
        fatalAlert.show()
    }
}
