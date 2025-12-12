//
//  SettingSwitchCell.swift
//  AppTemplate
//
//  Created by hubin.h on 2025/12/11.
//  Copyright © 2025 hubin.h. All rights reserved.

import Foundation

// MARK: - Global Variables & Functions (if necessary)

// MARK: - Main Class
class SettingSwitchCell: DefaultTableViewCell {
    
    lazy var switchView: UISwitch = {
        let view = UISwitch()
        return view
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        self.contentView.addSubview(switchView)
        self.switchView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
        }
        
        self.withThemeUpdates {[weak self] theme in
            guard let self else { return }
            // print("withThemeUpdates...\(theme)")
//            self.backgroundColor = theme.backgroundColor
//            self.textLabel?.textColor = theme.textColor
            self.switchView.tintColor = theme.tintColor
            self.switchView.onTintColor = theme.tintColor
        }
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func bind(to viewModel: TableViewCellViewModel) {
        super.bind(to: viewModel)
        guard let viewModel = viewModel as? SettingCellViewModel else { return }
        accessoryView = viewModel.hideNext ? nil: arrowView
        switchView.isHidden = !viewModel.hideNext
        switchView.rx.isOn <-> viewModel.switchChanged
    }
}

// MARK: - Private Methods
extension SettingSwitchCell {
}

// MARK: - Callbacks
extension SettingSwitchCell {
}

// MARK: - Utilities & Helpers
extension SettingSwitchCell {
}

// MARK: - Delegate & Data Source
extension SettingSwitchCell {
}
