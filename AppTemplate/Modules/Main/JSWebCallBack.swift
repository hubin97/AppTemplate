//
//  JSWebCallBack.swift
//  HBSwiftKit_Example
//
//  Created by hubin.h@wingto.cn on 2020/12/4.
//  Copyright © 2020 云图数字 All rights reserved.

import Foundation

// JSWebCallBack
extension JSWebController {
    
    // MARK: - jstest.html 示例方法
    @objc
    func nullParamCall() {
        print("nullParamCall - 由 JSWebCallBack 提供")
        self.nativeCallJs(with: nil)
    }
    
    @objc
    func haveParamCall1(_ param: String) {
        print("haveParamCall1 - 由 JSWebCallBack 提供, param:\(param)")
        self.nativeCallJs(with: param)
    }
    
    @objc
    func haveParamCall2(_ param: [String: Any]) {
        print("haveParamCall2 - 由 JSWebCallBack 提供, param:\(param)")
        self.nativeCallJs(with: param.string ?? "")
    }
    
    @objc
    func haveParamCall3(_ param: [Any]) {
        print("haveParamCall3 - 由 JSWebCallBack 提供, param:\(param)")
        self.nativeCallJs(with: param.string ?? "")
    }
}
