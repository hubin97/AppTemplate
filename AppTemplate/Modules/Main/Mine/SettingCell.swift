//
//  SettingCell.swift
//  AppTemplate
//
//  Created by hubin.h on 2025/12/11.
//  Copyright © 2025 hubin.h. All rights reserved.

import Foundation

// MARK: - Global Variables & Functions (if necessary)

// MARK: - Main Class
class SettingCell: DefaultTableViewCell {

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        accessoryView = arrowView
    }

    override func themeDidChange(_ theme: AppTheme) {
        super.themeDidChange(theme)
        titleLabel.textColor = theme.colors.tint
        detailLabel.textColor = theme.colors.tint
    }

    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func bind(to viewModel: TableViewCellViewModel) {
        super.bind(to: viewModel)
        guard viewModel is SettingCellViewModel else { return }
    }
}

// MARK: - Private Methods
extension SettingCell {
}

// MARK: - Callbacks
extension SettingCell {
}

// MARK: - Utilities & Helpers
extension SettingCell {
}

// MARK: - Delegate & Data Source
extension SettingCell {
}
