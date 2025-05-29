//
//  WebInteractController.swift
//  Momcozy
//
//  Created by hubin.h on 2024/11/8.
//  Copyright © 2025 Hubin_Huang. All rights reserved.

import Foundation

// MARK: - global var and methods

// MARK: - main class
open class WebInteractController: WKWebController, WebInteractable {
    
    /// 注册js交互
    /// self.registerJsCallNative(with: LUTE_NATIVE)
//    override func setupLayout() {
//        super.setupLayout()
//    }
}

// MARK: - private mothods
extension WebInteractController { 
    
    // MARK: - jstest.html 示例方法
    @objc
    func nullParamCall() {
        print("nullParamCall - 由 WebInteractController 提供")
        self.nativeCallJs(with: nil)
    }
    
    @objc
    func haveParamCall1(_ param: String) {
        print("haveParamCall1 - 由 WebInteractController 提供, param:\(param)")
        self.nativeCallJs(with: param)
    }
    
    @objc
    func haveParamCall2(_ param: [String: Any]) {
        print("haveParamCall2 - 由 WebInteractController 提供, param:\(param)")
        self.nativeCallJs(with: param.string ?? "")
    }
    
    @objc 
    func haveParamCall3(_ param: [Any]) {
        print("haveParamCall3 - 由 WebInteractController 提供, param:\(param)")
        self.nativeCallJs(with: param.string ?? "")
    }
}
