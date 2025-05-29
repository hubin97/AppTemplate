//
//  WebPreviewController.swift
//  HBSwiftKit_Example
//
//  Created by hubin.h@wingto.cn on 2020/12/4.
//  Copyright © 2020 云图数字 All rights reserved.

import Foundation

// MARK: - global var and methods
private let LUTE_NATIVE = "LUTE_NATIVE"

// MARK: - main class
class WebPreviewController: WebInteractController {

    override func setupLayout() {
        super.setupLayout()
        self.naviBar.title = "Web Preview"
        self.registerJsCallNative(with: LUTE_NATIVE)
        
        self.loadWeb(urlPath: "jstest.html", isLocalHtml: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.naviBar.leftView?.isHidden = true
    }
    
    func nativeCallJs(with jsonString: String?) {
        print("native调用外部js方法")
    }
}
