//
//  JSWebController.swift
//  AppTemplate
//
//  Created by hubin.h on 2025/9/25.
//  Copyright © 2025 路特创新. All rights reserved.

import Foundation
import AppStart

// MARK: - Global Variables & Functions (if necessary)

// MARK: - Main Class
class JSWebController: WKWebController, WebInteractable, ViewModelProvider {
    typealias ViewModelType = JSWebViewModel
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let symbol = vm.symbol {
            self.registerJsCallNative(with: symbol)
        }
    }
}

// MARK: - Private Methods
extension JSWebController {
    
    @objc func activityNavigator(_ params: [String: Any]) {
        iToast.makeToast("activityNavigator: \(params.string ?? "")")
    }
}

// MARK: - Callbacks
extension JSWebController {
}

// MARK: - Utilities & Helpers
extension JSWebController {
}

// MARK: - Delegate & Data Source
extension JSWebController {
}
