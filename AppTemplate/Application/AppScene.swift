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
 
    case safari(URL)
    // 仅支持 alert 推出,使用其它方式, 可能会导致无法返回或者UI显示异常
    case videoPlayController(url: String, autoPlay: Bool = true)
    case tabs(viewModel: TabBarViewModel)
    case imageDecoder
    case jsWeb(path: String, title: String?, symbol: String?)
    
    // MARK: -
    var getSegue: UIViewController? {
        switch self {
        case .safari(let url):
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            return nil
        case .videoPlayController(let url, let autoPlay):
            let vc = AVPlayerViewController()
            if let playUrl = URL(string: url) {
                let player = AVPlayer(url: playUrl)
                vc.player = player
                if autoPlay {
                    player.play()
                }
            }
            return vc
        case .tabs(let viewModel):
            let tabBarVc = TabBarController(viewModel: viewModel)
            tabBarVc.setAppearance(normalColor: UIColor.lightGray, selectColor: UIColor.black)
            return tabBarVc
        case .imageDecoder:
            return ImageDecoderController(viewModel: nil)
        case .jsWeb(let path, let title, let symbol):
            let vc = JSWebController(viewModel: JSWebViewModel(symbol: symbol))
            vc.setTitle(title)
            vc.loadWeb(urlPath: path)
            return vc
        }
    }
}
