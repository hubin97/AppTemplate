//
//  DefaultWebController.swift
//  AppTemplate
//
//  Created by hubin.h on 2025/12/12.
//  Copyright © 2025 hubin.h. All rights reserved.

import Foundation

// MARK: - Global Variables & Functions (if necessary)

// MARK: - Main Class
class DefaultWebController: JSWebController, Themeable {

//    override var bridgeHandlers: [String: WebBridgeHandler] {
//        [
//            "nullParamCall": WebBridgeHandler.bridge(nullParamCall),
//            "haveParamCall1": WebBridgeHandler.bridge(haveParamCall1),
//            "haveParamCall2": WebBridgeHandler.bridge(haveParamCall2),
//            "haveParamCall3": WebBridgeHandler.bridge(haveParamCall3)
//        ]
//    }
    
    override func bindViewModel() {
        super.bindViewModel()
        startThemeUpdates()
    }

    func themeDidChange(_ theme: AppTheme) {
        applyPageTheme(theme)
        progressViewTintColor = theme.colors.tint
    }
}

// MARK: - Private Methods
extension DefaultWebController {
}

// MARK: - Callbacks
extension DefaultWebController {
}

// MARK: - Utilities & Helpers
extension DefaultWebController {
}

// MARK: - Delegate & Data Source
extension DefaultWebController {
}
