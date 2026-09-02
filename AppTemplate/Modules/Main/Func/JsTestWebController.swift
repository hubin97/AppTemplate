//
//  JsTestWebController.swift
//  AppTemplate
//
//  Created by hubin.h on 2026/9/2.
//  Copyright © 2025 Hubin.Huang. All rights reserved.

import Foundation

// MARK: - Global Var and Methods

// MARK: - Main Class
class JsTestWebController: DefaultWebController {
    
    override var bridgeHandlers: [String : WebBridgeHandler] {
        [
            "nullParamCall": WebBridgeHandler.bridge(nullParamCall),
            "haveParamCall1": WebBridgeHandler.bridge(haveParamCall1),
            "haveParamCall2": WebBridgeHandler.bridge(haveParamCall2),
            "haveParamCall3": WebBridgeHandler.bridge(haveParamCall3)
        ]
    }
}

// MARK: - Private Methods
extension JsTestWebController {
}

// MARK: - Callbacks
extension JsTestWebController {
    
    // MARK: - jstest.html 示例方法
    func nullParamCall() {
        print("nullParamCall - 由 \(self) 提供")
        self.nativeCallJs(with: nil)
    }
    
    func haveParamCall1(_ param: String) {
        print("haveParamCall1 - 由 \(self) 提供, param:\(param)")
        self.nativeCallJs(with: param)
    }
    
    func haveParamCall2(_ param: [String: Any]) {
        print("haveParamCall2 - 由 \(self) 提供, param:\(param)")
        self.nativeCallJs(with: param)
    }
    
    func haveParamCall3(_ param: [Any]) {
        print("haveParamCall3 - 由 \(self) 提供, param:\(param)")
        self.nativeCallJs(with: param)
    }
}

// MARK: - Delegate & Data Source
extension JsTestWebController {
}

// MARK: - Utilities & Helpers
extension JsTestWebController {
}
