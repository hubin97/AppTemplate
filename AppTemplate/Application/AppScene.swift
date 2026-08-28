//
//  AppScene.swift
//  HBSwiftKit_Example
//
//  Created by hubin.h on 2024/12/3.
//  Copyright © 2025 Hubin_Huang. All rights reserved.

import Foundation
import AVKit

// MARK: - global var and methods
enum AppScene: SceneProvider {
 
    case tabs(viewModel: TabBarViewModel)
    case jsTest
    case imageDecoder
    case lottieHUD
    case battery
    case batteryLegacy
    case powerBattery
    case iap
    case bleTest
    case bleScan
    case bleDiscovery
    case bleBoundList
    case bleDevicePanel(uuid: String)
    case bleCentralState
    case bleConnection
    case authPermission
    case connectivity
    /// 分域路由 Demo（AppRouter + RouteRegister + ViewModel）
    case appRouterDemo
    
    // MARK: -
    var getSegue: UIViewController? {
        switch self {
        case .tabs(let viewModel):
            return DefaultTabBarController(viewModel: viewModel)
        case .jsTest:
            let vc = DefaultWebController(viewModel: JSWebViewModel(symbol: "LUTE_NATIVE"))
            //vc.isHideLeftView = true
            vc.loadWeb(urlPath: "jstest.html", isLocal: true)
            return vc
        case .imageDecoder:
            return ImageDecoderController(viewModel: nil)
        case .lottieHUD:
            return ProgressHUDLottieController(viewModel: nil)
        case .battery:
            return BatteryDemoListController(viewModel: nil)
        case .batteryLegacy:
            return LegacyBatteryDemoController(viewModel: nil)
        case .powerBattery:
            return PowerBatteryDemoController(viewModel: nil)
        case .iap:
            return IAPViewController(viewModel: nil)
        case .bleTest:
            return BleTestListController(viewModel: nil)
        case .bleScan, .bleDiscovery:
            return BleDiscoveryListController(viewModel: nil)
        case .bleBoundList:
            return BleBoundDeviceListController(viewModel: BleBoundDeviceListViewModel())
        case .bleDevicePanel(let uuid):
            return BleDevicePanelFactory.make(uuid: uuid)
        case .bleCentralState:
            return BleCentralStateController(viewModel: nil)
        case .bleConnection:
            return BleConnectionController(viewModel: nil)
        case .authPermission:
            return AuthPermissionDemoController(viewModel: nil)
        case .connectivity:
            return ConnectivityDemoController(viewModel: nil)
        case .appRouterDemo:
            return HomeDemoController(viewModel: HomeViewModel())
        }
    }
}
