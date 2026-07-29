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
