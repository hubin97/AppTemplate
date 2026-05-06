//
//  DynamicSettingsCell.swift
//  AppTemplate
//
//  Created by hubin.h on 2026/5/4.
//  Copyright © 2025 hubin.h. All rights reserved.

import Foundation
import RxSwift
import RxCocoa

// MARK: - Global Variables & Functions (if necessary)

// MARK: - Main Class

class DynamicSettingsCell: DefaultTableViewCell {

    lazy var switchView: UISwitch = {
        let view = UISwitch()
        return view
    }()

    private var disposeBag = DisposeBag()

    private let sideInset: CGFloat = 16
    private let verticalInset: CGFloat = 8
    private let textToSwitchSpacing: CGFloat = 12

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(switchView)

        withThemeUpdates { (self, theme) in
            self.switchView.tintColor = theme.tintColor
            self.switchView.onTintColor = theme.tintColor
        }
    }

    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
        switchView.isHidden = true
        accessoryView = arrowView
        selectionStyle = .default
    }

    func configure(item: SettingItemModel, onToggle: ((Bool) -> Void)?) {
        titleLabel.text = item.title
        titleLabel.isHidden = item.title.isEmpty

        let sub = item.subtitle ?? ""
        let det = item.detail ?? ""
        let finalDetail: String?
        if !sub.isEmpty, !det.isEmpty, sub != det {
            finalDetail = "\(sub) · \(det)"
        } else {
            finalDetail = sub.isEmpty ? det : sub
        }
        detailLabel.text = finalDetail
        detailLabel.isHidden = (finalDetail ?? "").isEmpty

        let isToggle = item.type == DynamicSettingItemType.toggle
        switchView.isHidden = !isToggle
        accessoryView = isToggle ? nil : arrowView
        selectionStyle = isToggle ? .none : .default

        stackView.snp.remakeConstraints { (make) in
            make.top.equalToSuperview().inset(verticalInset)
            make.bottom.equalToSuperview().inset(verticalInset)
            make.leading.equalToSuperview().inset(sideInset)
            if isToggle {
                make.trailing.lessThanOrEqualTo(switchView.snp.leading).offset(-textToSwitchSpacing)
            } else {
                make.trailing.equalToSuperview().inset(sideInset)
            }
        }

        switchView.snp.remakeConstraints { (make) in
            make.trailing.equalToSuperview().inset(sideInset)
            make.centerY.equalToSuperview()
            if !isToggle {
                make.width.height.equalTo(0)
            }
        }

        if isToggle {
            switchView.isEnabled = item.enabled
            switchView.isOn = item.payload.boolValue ?? false
            switchView.rx.controlEvent(.valueChanged)
                .map { [weak self] in self?.switchView.isOn ?? false }
                .subscribe(onNext: { onToggle?($0) })
                .disposed(by: disposeBag)
        }
    }
}

// MARK: - Private Methods
extension DynamicSettingsCell {
}

// MARK: - Callbacks
extension DynamicSettingsCell {
}

// MARK: - Utilities & Helpers
extension DynamicSettingsCell {
}

// MARK: - Delegate & Data Source
extension DynamicSettingsCell {
}
