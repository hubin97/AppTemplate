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
    case iap
    case dynamicSettingsDemo
    case businessSettingsDemoA
    case businessSettingsDemoB
    
    // MARK: -
    var getSegue: UIViewController? {
        switch self {
        case .tabs(let viewModel):
            let normalColor = viewModel.tabBarItems.first?.textColor_n ?? .lightGray
            let selectColor = viewModel.tabBarItems.first?.textColor_h ?? .black
            let tabBarVc = DefaultTabBarController(viewModel: viewModel)
            tabBarVc.setAppearance(normalColor: normalColor, selectColor: selectColor)
            return tabBarVc
        case .jsTest:
            let vc = DefaultWebController(viewModel: JSWebViewModel(symbol: "LUTE_NATIVE"))
            //vc.isHideLeftView = true
            vc.loadWeb(urlPath: "jstest.html", isLocal: true)
            return vc
        case .imageDecoder:
            return ImageDecoderController(viewModel: nil)
        case .iap:
            return IAPViewController(viewModel: nil)
        case .dynamicSettingsDemo:
            return DynamicSettingsViewController(
                viewModel: DynamicSettingsViewModel(panelSource: DynamicSettingsDefaultPanelSource()),
                navigator: Application.shared.navigator
            )
        case .businessSettingsDemoA:
            let panelSource = DynamicSettingsLocalPanelSource.resolvingOrFallback(resource: "panelA")
            return BusinessSettingsDemoAController(
                viewModel: DynamicSettingsViewModel(panelSource: panelSource),
                navigator: Application.shared.navigator
            )
        case .businessSettingsDemoB:
            let panelSourceB = DynamicSettingsLocalPanelSource.resolvingOrFallback(resource: "panelB")
            return BusinessSettingsDemoBController(
                viewModel: DynamicSettingsViewModel(panelSource: panelSourceB),
                navigator: Application.shared.navigator
            )
        }
    }
}
