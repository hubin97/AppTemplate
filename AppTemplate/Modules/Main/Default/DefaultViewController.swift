//
//  DefaultViewController.swift
//  AppTemplate
//
//  Created by hubin.h on 2025/12/12.
//  Copyright © 2025 hubin.h. All rights reserved.

import Foundation

// MARK: - Global Variables & Functions (if necessary)

// MARK: - Main Class
class DefaultViewController: ViewController, Themeable {
    
    override func bindViewModel() {
        super.bindViewModel()
        withThemeUpdates {[weak self] theme in
            guard let self else { return }
            print("DefaultViewController-withThemeUpdates")
            self.view.backgroundColor = theme.backgroundColor
            self.naviBar.backgroundColor = theme.backgroundColor
            self.naviBar.textColor = theme.textColor
            setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return ThemeService.shared.current.statusBarStyle
    }
  
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .allButUpsideDown
    }
}

// MARK: - Private Methods
extension DefaultViewController {
}

// MARK: - Callbacks
extension DefaultViewController {
}

// MARK: - Utilities & Helpers
extension DefaultViewController {
}

// MARK: - Delegate & Data Source
extension DefaultViewController {
}
