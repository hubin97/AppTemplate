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
 
    case jsTest
    case imageDecoder
    
    // MARK: -
    var getSegue: UIViewController? {
        switch self {
        case .jsTest:
            let vc = JSWebController(viewModel: JSWebViewModel(symbol: "LUTE_NATIVE"))
            //vc.isHideLeftView = true
            vc.loadWeb(urlPath: "jstest.html", isLocal: true)
            return vc
        case .imageDecoder:
            return ImageDecoderController(viewModel: nil)
        }
    }
}
