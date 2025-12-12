//
//  DefaultTabBarController.swift
//  AppTemplate
//
//  Created by hubin.h on 2025/12/12.
//  Copyright © 2025 hubin.h. All rights reserved.

import Foundation

// MARK: - Global Variables & Functions (if necessary)

// MARK: - Main Class
class DefaultTabBarController: TabBarController, Themeable {
    
    override func bindViewModel() {
        super.bindViewModel()
     
        self.withThemeUpdates {[weak self] theme in
            guard let self else { return }
            let normalColor: UIColor = .lightGray
            let selectColor: UIColor = theme is LightTheme ? .black: .white
            self.setAppearance(barTintColor: theme.backgroundColor, normalColor: normalColor, selectColor: selectColor)
            //self.view.backgroundColor = theme.backgroundColor
        }
    }
}

// MARK: - Private Methods
extension DefaultTabBarController {
}

// MARK: - Callbacks
extension DefaultTabBarController {
}

// MARK: - Utilities & Helpers
extension DefaultTabBarController {
}

// MARK: - Delegate & Data Source
extension DefaultTabBarController {
}
