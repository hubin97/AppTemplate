//
//  AuthManager.swift
//  Momcozy
//
//  Created by hubin.h on 2024/5/13.
//  Copyright © 2025 Hubin_Huang. All rights reserved.

import Foundation
//import KeychainAccess
import ObjectMapper
import RxSwift
import RxCocoa

/// 是否登录
let loggedIn = BehaviorRelay<Bool>(value: false)

// MARK: 项目内标识信息
enum AppKeys: String {
    case app_id = "xxx"
    case bundle_id = "com.root.lutego"
    case uid
    case email
    case phone
    case password
    case token
}

// MARK: - AuthManager
class AuthManager {

    static let shared = AuthManager()

    // MARK: - Properties
//    fileprivate let tokenKey = "TokenKey"
//    fileprivate let keychain = Keychain(service: AppKeys.bundle_id.rawValue)
    init() {
        //loggedIn.accept(hasValidToken)
    }

    //FIXME: 暂时取消钥匙串方案
//    var token: LoginModel? {
//        get {
//            guard let jsonString = keychain[tokenKey] else { return nil }
//            return Mapper<LoginModel>().map(JSONString: jsonString)
//        }
//        set {
//            if let token = newValue, let jsonString = token.toJSONString() {
//                keychain[tokenKey] = jsonString
//            } else {
//                keychain[tokenKey] = nil
//            }
//        }
//    }
    
//    var token: LoginModel? {
//        get {
//            guard let jsonString = UserDefaults.standard.string(forKey: AppKeys.token.rawValue) else { return nil }
//            return Mapper<LoginModel>().map(JSONString: jsonString)
//        }
//        set {
//            if let token = newValue, let jsonString = token.toJSONString() {
//                UserDefaults.standard.set(jsonString, forKey: AppKeys.token.rawValue)
//            } else {
//                UserDefaults.standard.set(nil, forKey: AppKeys.token.rawValue)
//            }
//            UserDefaults.standard.synchronize()
//        }
//    }
//
//    /// Token 是否有效
//    var hasValidToken: Bool {
//        return token?.isValid == true
//    }
//
//    class func setToken(token: LoginModel) {
//        AuthManager.shared.token = token
//        //AuthManager.setTokenValid(true)
//    }
//
//    class func removeToken() {
//        AuthManager.shared.token = nil
//        //AuthManager.setTokenValid(false)
//    }
//
//    class func setTokenValid(_ isValid: Bool) {
//        AuthManager.shared.token?.isValid = isValid
//        loggedIn.accept(isValid)
//    }
}

// MARK: 补充用户信息
extension AuthManager {
    
    private(set) var uid: String? {
        get {
            UserDefaults.standard.string(forKey: AppKeys.uid.rawValue)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: AppKeys.uid.rawValue)
            UserDefaults.standard.synchronize()
        }
    }

    private(set) var email: String? {
        get {
            UserDefaults.standard.string(forKey: AppKeys.email.rawValue)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: AppKeys.email.rawValue)
            UserDefaults.standard.synchronize()
        }
    }
    
    private(set) var phone: String? {
        get {
            UserDefaults.standard.string(forKey: AppKeys.phone.rawValue)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: AppKeys.phone.rawValue)
            UserDefaults.standard.synchronize()
        }
    }

    /// 注意`base64加密存取`
    private(set) var password: String? {
        get {
            UserDefaults.standard.string(forKey: AppKeys.password.rawValue)?.base64Decode()
        }
        set {
            UserDefaults.standard.set(newValue?.base64Encode(), forKey: AppKeys.password.rawValue)
            UserDefaults.standard.synchronize()
        }
    }
  
    //
    class func setUid(_ uid: String?) {
        AuthManager.shared.uid = uid
    }
    
    class func setEmail(_ email: String?) {
        AuthManager.shared.email = email
    }
    
    class func setPhone(_ phone: String?) {
        AuthManager.shared.phone = phone
    }

    class func setPassword(_ password: String?) {
        AuthManager.shared.password = password
    }
    
    class func removeUid() {
        AuthManager.shared.uid = nil
    }
    
    class func removePassword() {
        AuthManager.shared.password = nil
    }
    
    class func removeUserInfo() {
        AuthManager.shared.uid = nil
        AuthManager.shared.email = nil
        AuthManager.shared.phone = nil
        AuthManager.shared.password = nil
    }
}
