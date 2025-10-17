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
    // 仅支持 modal,alert 推出,使用其它方式, 可能会导致无法返回或者UI显示异常
    // ❌ 1.modal(x) + isWrap(false) 显示异常
    // ✅ 2.modal(x) + isWrap(true): 全屏, overFullScreen 不执行viewWillDisappear; fullScreen执行viewWillDisappear
    // ✅ 3.alert(x) + isWrap(false): 全屏 都执行viewWillDisappear
    // ❌ 4.alert(x) + isWrap(true) x失效, 半屏, 都不执行viewWillDisappear; 为什么和另外一个项目不一样???
    // 无脑选方案2, 如果不考虑是否执行viewWillDisappear, 2,3方案都行; 如果考虑是否执行viewWillDisappear, 选方案2
    // isWrap决定推出时,当前页是否执行viewWillDisappear, 默认isWrap=fasle, 会执行, 否则不执行
    case videoPlayController(url: String, autoPlay: Bool = true, isWrap: Bool = false)
    case tabs(viewModel: TabBarViewModel)
    case imageDecoder
    case jsWeb(path: String, title: String?, symbol: String?)
    
    // MARK: -
    var getSegue: UIViewController? {
        switch self {
        case .safari(let url):
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            return nil
        case .videoPlayController(let url, let autoPlay, let isWrap):
            let vc = AVPlayerViewController()
            if let playUrl = URL(string: url) {
                let player = AVPlayer(url: playUrl)
                vc.player = player
                if autoPlay {
                    player.play()
                }
            }
            if isWrap {
                let wrapVc = ViewController()
                wrapVc.view.backgroundColor = .clear
                wrapVc.naviBar.isHidden = true
                
                vc.view.frame = wrapVc.view.bounds
                wrapVc.addChild(vc)
                wrapVc.view.addSubview(vc.view)
                vc.didMove(toParent: wrapVc)
                return wrapVc
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
