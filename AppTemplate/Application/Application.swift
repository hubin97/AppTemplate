//
//  Application.swift
//  Petcozy
//
//  Created by hubin.h on 2024/5/23.
//  Copyright © 2025 Hubin_Huang. All rights reserved.

import Foundation

// MARK: - global var and methods
let RLocalizable = R.string.localizable

// MARK: - main class
final class Application: NSObject {
    
    static let shared = Application()

    var window: UIWindow?

    /// 网络是否可用
    var isNetworkAvailable = false
    /// 埋点会话Id
    let sessionId = UUID().uuidString
    /// 路由
    let navigator: Navigator
    /// 协议版本号, 注意, 服务器默认`最小版本是1`
    var pVersionNum: Int?
 
    private override init() {
        navigator = Navigator.default
        super.init()
        
        // 设置监听
        setupMonitoring()
        // 网络检测
        networkListening()
    }
}

// MARK: - 
extension Application {
    
    /// 更新配置项
    func setupConfig() {
        self.setupLocalized()

    }
    
    func setupLocalized() {
        LocalizedUtils.setupLocalized()
    }
    
//    func setupPluginsConfig() {
//        NetworkPrintlnPlugin.showLoggers = showNetworkLogs
//    }
}

// MARK: -
extension Application {
    
    /// 设置全局监听项
    func setupMonitoring() {
//        NotificationCenter.default.rx.notification(Notification.Name.Login).subscribe(onNext: {[weak self] _ in
//            self?.initialScreen(in: self?.window)
//        }).disposed(by: rx.disposeBag)
    }
}

// MARK: - call backs
extension Application {
    
    func launch(in window: UIWindow?) {
        guard let window = window else { return }
        self.window = window
        self.setupConfig()
        
        // 禁用夜间模式
        if #available(iOS 13.0, *) {
            window.overrideUserInterfaceStyle = .light
        }
        window.rootViewController = UIViewController()
        window.makeKeyAndVisible()
        
        LogM.debug("app launch")
        
        // 自定义启动页
        self.initialScreen(in: window)
    }
    
    func initialScreen(in window: UIWindow?) {
        guard let window = window else { return }
        
//        /// 登录状态是否有效
//        guard AuthManager.shared.hasValidToken else {
//            //self.navigator.show(segue: .login(viewModel: LoginViewModel()), sender: nil, transition: .root(in: window))
//            self.navigator.show(segue: .loginRegister, sender: nil, transition: .root(in: window))
//            return
//        }
               
        /// 主页
        self.navigator.show(provider: AppScene.tabs(viewModel: TabBarViewModel(tabBarItems: TabBarItem.allCases)), sender: nil, transition: .root(in: window))
    }
}

// MARK: - delegate or data source
extension Application { 
    
    // 检测网络权限变更
    func networkListening() {
        // import Network, NWPathMonitor 有些问题, APP启动时总数检测为蜂窝网络
        connectedToInternet()/*.skip(1)*/.subscribe(onNext: {[weak self] status in
            if status == .notReachable {
                self?.isNetworkAvailable = false
                iToast.makeToast(RLocalizable.app_no_internet_tips.key.localized)
            } else {
                // 网络可用
                self?.isNetworkAvailable = true
                self?.networkReachable()
                if status == .reachable(.cellular) {
                    iToast.makeToast(RLocalizable.app_use_mobile_data_tips.key.localized)
                }
            }
        }).disposed(by: rx.disposeBag)
    }
    
    func networkReachable() {
//        /// `用户协议版本`校验
//        getPublicConfig().done { config in
//            DataManager.setPConfigModel(config)
//        }.catch { error in
//            print(error.localizedDescription)
//        }
//        
//        /// `token`有效性校验
//        if AuthManager.shared.token != nil {
//            /// `refreshToken`接口暂时有问题
////            refreshToken(token: token).done { newToken in
////                AuthManager.setToken(token: newToken)
////                AuthManager.setTokenValid(true)
////            }.catch { error in
////                print(error.localizedDescription)
////            }
//            LoginRequest.checkToken().done { status in
//                AuthManager.setTokenValid(status)
//            }.catch { error in
//                print(error.localizedDescription)
//            }
//        }
    }
}
