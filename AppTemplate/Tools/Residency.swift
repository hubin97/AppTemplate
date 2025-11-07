//
//  Residency.swift
//  Momcozy
//
//  Created by hubin.h on 2025/8/7.
//  Copyright © 2025 路特创新. All rights reserved.

/// TikTok 在 iOS 端实现大陆用户登录注册限制的技术方案
/// https://rcmdkv7gnx.feishu.cn/wiki/TT45woMPzi1ac4kLH2vcm1nYnMi
///
import Foundation
import CoreTelephony
import PromiseKit

// MARK: - Global Variables & Functions (if necessary)

// MARK: - Main Class
class Residency {
    
    static let shared = Residency()

    /// 是否是居住中国大陆的用户
    /// 系统语言一定是中文, 地区是大陆; 如果没插卡运营商可能获取为空
    var isMainlandUser: Bool {
        return (isUsingChineseCarrier || isUserFromMainlandChina)
    }
    
    func setup() {
        //self.getCloudResult()
    }
}

// MARK: - Private Methods
extension Residency {
    
    // 获取云端校验结果
//    private func getCloudResult() {
//        // APP启动 且 选中地区为空时执行
//        guard AuthManager.shared.region == nil else { return }
//        // LogM.debug("根据IP定位用户归属地")
//        LoginRequest.getUserRegion().done { region in
//            if let region = region, self.isMainlandUser {
//                AuthManager.setRegion(region)
//                // 同时写入地区隐私协议版本
//                DataManager.setPVersionNum(region.privacyVersion)
//            }
//        }.catch { error in
//            print(error.localizedDescription)
//        }
//    }
}

// MARK: - Callbacks
extension Residency {
}

// MARK: - Utilities & Helpers
extension Residency {
    
    /// 是否中国大陆运营商
    private var isUsingChineseCarrier: Bool {
        let networkInfo = CTTelephonyNetworkInfo()
        guard let carriers = networkInfo.serviceSubscriberCellularProviders else {
            return false
        }
        return carriers.values.contains { carrier in
            carrier.mobileCountryCode == "460" || carrier.isoCountryCode?.lowercased() == "cn"
        }
    }
    
    /// 系统设置地区和语言为大陆的用户
    private var isUserFromMainlandChina: Bool {
        let regionCode = Locale.current.regionCode ?? ""
        let preferredLanguage = Locale.preferredLanguages.first ?? ""
        return regionCode.uppercased() == "CN" && preferredLanguage.contains("zh")
    }
}

// MARK: - Delegate & Data Source
extension Residency {
}
