//
//  LibsManager.swift
//  Momcozy
//
//  Created by hubin.h on 2024/5/13.
//  Copyright © 2025 Hubin_Huang. All rights reserved.

import Foundation
import IQKeyboardManagerSwift
import Toast_Swift
import ProgressHUD
import Kingfisher
import CocoaLumberjack
import Bugly
import MMKV
import KingfisherWebP
//import KingfisherSVG
//import Firebase

// MARK: - global var and methods

// MARK: - main class
class LibsManager {
    
    static let shared = LibsManager()
    
    @MainActor func setupLibs() {
        let libsManager = LibsManager.shared
        libsManager.setupMMKV()
        libsManager.setupFirebase()
        libsManager.setupBugly()
        libsManager.setupToast()
        libsManager.setupProgressHUD()
        libsManager.setupKeyboardManager()
        libsManager.setupKingfisher()
        libsManager.setupLogger()
    }
}

// MARK: - private mothods
extension LibsManager {
    
    func setupMMKV() {
        MMKVManager.shared.initMMKV()
    }
    
    func setupFirebase() {
        //FirebaseApp.configure()
    }
    
    func setupBugly() {
#if DEBUG
#else
        Bugly.start(withAppId: "ef2148c327")
#endif
    }

    func setupToast() {
        ToastManager.shared.isTapToDismissEnabled = true
        ToastManager.shared.duration = 2.0
        ToastManager.shared.position = .center
        ToastManager.shared.style.cornerRadius = 5
        ToastManager.shared.style.backgroundColor = .systemGroupedBackground
    }
    
    func setupProgressHUD() {      
        ProgressHUD.colorAnimation = Colors.main
        ProgressHUD.colorStatus = Colors.main
        ProgressHUD.fontStatus = Fonts.figma(.w400)(17)
        ProgressHUD.colorProgress = Colors.main
        ProgressHUD.animationType = .circleStrokeSpin
        //ProgressHUD.imageSuccess = R.image.icon_hud_success()!
        //ProgressHUD.imageError = R.image.icon_hud_error()!
    }
    
    @MainActor func setupKeyboardManager() {
        IQKeyboardManager.shared.isEnabled = true
    }
 
    func setupKingfisher() {
        // 设置默认缓存的最大磁盘缓存大小。 默认值为0，表示没有限制。// 500 MB
        ImageCache.default.diskStorage.config.sizeLimit = UInt(500 * 1024 * 1024)
        // 设置缓存在磁盘中存储的最长时间。 默认值为 1 周
        ImageCache.default.diskStorage.config.expiration = .days(7)
        // 设置默认图像下载器的超时时间。 默认值为 15 秒。
        ImageDownloader.default.downloadTimeout = 15.0
        
        // 全局注册 WebP 解码器
        KingfisherManager.shared.defaultOptions += [
          .processor(WebPProcessor.default),
          .cacheSerializer(WebPSerializer.default)
        ]
        
//        KingfisherManager.shared.defaultOptions += [
//            .processor(SVGProcessor.default),
//            .cacheSerializer(SVGCacheSerializer.default)
//        ]
    }

    func setupCocoaLumberjack() {
        DDLog.add(DDOSLogger.sharedInstance)
        let fileLogger: DDFileLogger = DDFileLogger() // File Logger
        fileLogger.rollingFrequency = TimeInterval(60*60*24)  // 24 hours
        fileLogger.logFileManager.maximumNumberOfLogFiles = 7
        DDLog.add(fileLogger)
    }
    
    /// 开启日志管理
    /// 注意 `网络接口调用, release模式下默认不写入日志文件`
    func setupLogger() {
        let logLevel = DDLogLevel.verbose
#if DEBUG
        //LogM.shared.launch(logLevel, logMode: .detail).entrance(R.image.lanuch_logo())
        LogM.shared.setup(level: logLevel, consoleMode: .easy, fileMode: .detail).entrance()
        NetworkPrintlnPlugin.shared.loglevel = logLevel
#else
        //LogM.shared.level(logLevel).file(.detail).launch()
        LogM.shared.setup(level: logLevel).launch()
#endif
    }
}

// MARK: - call backs
extension LibsManager { 
}

// MARK: - delegate or data source
extension LibsManager { 
}

// MARK: - other classes
