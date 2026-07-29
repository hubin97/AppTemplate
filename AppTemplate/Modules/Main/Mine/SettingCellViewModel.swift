//
//  SettingCellViewModel.swift
//  AppTemplate
//
//  Created by hubin.h on 2025/12/11.
//  Copyright © 2025 hubin.h. All rights reserved.

import Foundation
import RxCocoa
// MARK: - Global Variables & Functions (if necessary)

// MARK: - Main Class
class SettingCellViewModel: DefaultTableViewCellViewModel {

    let itemType: SettingItem

    init(itemType: SettingItem) {
        self.itemType = itemType
        super.init()

        self.title.accept(itemType.title)

        switch itemType {
        case .displayMode(let mode):
            self.detail.accept(mode.displayName)
        case .themePalette(let palette):
            self.detail.accept(palette.displayName)
        case .language(let language):
            self.detail.accept(language.rawValue)
        case .clearCache:
            break
        case .aboutUs:
            break
        }
    }
}

// MARK: - Private Methods
extension SettingCellViewModel {
}

// MARK: - Callbacks
extension SettingCellViewModel {
}

// MARK: - Utilities & Helpers
extension SettingCellViewModel {
}

// MARK: - Delegate & Data Source
extension SettingCellViewModel {
}
