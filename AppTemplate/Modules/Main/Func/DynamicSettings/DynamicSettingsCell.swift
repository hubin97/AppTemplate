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

    private lazy var actionContainerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 10
        view.clipsToBounds = true
        view.isHidden = true
        return view
    }()

    private lazy var actionTitleLabel: UILabel = {
        let view = UILabel()
        view.textAlignment = .center
        view.numberOfLines = 1
        view.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        return view
    }()

    private var disposeBag = DisposeBag()

    private let sideInset: CGFloat = 16
    private let verticalInset: CGFloat = 8
    private let textToSwitchSpacing: CGFloat = 12

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(switchView)
        contentView.addSubview(actionContainerView)
        actionContainerView.addSubview(actionTitleLabel)

        actionContainerView.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().inset(sideInset)
            make.trailing.equalToSuperview().inset(sideInset)
            make.top.equalToSuperview().inset(verticalInset)
            make.bottom.equalToSuperview().inset(verticalInset)
            make.height.greaterThanOrEqualTo(44)
        }
        actionTitleLabel.snp.makeConstraints { (make) in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 10, left: 8, bottom: 10, right: 8))
        }

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
        actionContainerView.isHidden = true
        accessoryView = arrowView
        selectionStyle = .default
        titleLabel.numberOfLines = 1
        detailLabel.numberOfLines = 1
        detailLabel.font = detailLabel.font.withSize(14)
    }

    func configure(item: SettingItemModel, onToggle: ((Bool) -> Void)?) {
        let style = item.viewStyle ?? DynamicSettingViewStyle.plain
        if style == DynamicSettingViewStyle.primaryAction || style == DynamicSettingViewStyle.dangerAction {
            configureActionStyle(item: item, style: style)
            return
        }

        actionContainerView.isHidden = true
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

        configureTextStyle(style)

        let isToggle = item.type == DynamicSettingItemType.toggle && style == DynamicSettingViewStyle.plain
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
    private func configureTextStyle(_ style: String) {
        switch style {
        case DynamicSettingViewStyle.deviceCard:
            titleLabel.numberOfLines = 1
            detailLabel.numberOfLines = 2
            detailLabel.font = detailLabel.font.withSize(12)
        default:
            titleLabel.numberOfLines = 1
            detailLabel.numberOfLines = 1
            detailLabel.font = detailLabel.font.withSize(14)
        }
    }

    private func configureActionStyle(item: SettingItemModel, style: String) {
        titleLabel.isHidden = true
        detailLabel.isHidden = true
        switchView.isHidden = true
        accessoryView = nil
        selectionStyle = .default
        actionContainerView.isHidden = false
        actionTitleLabel.text = item.title

        switch style {
        case DynamicSettingViewStyle.dangerAction:
            actionContainerView.backgroundColor = UIColor.systemRed.withAlphaComponent(0.12)
            actionTitleLabel.textColor = .systemRed
        default:
            actionContainerView.backgroundColor = UIColor.black.withAlphaComponent(0.85)
            actionTitleLabel.textColor = .white
        }

        stackView.snp.remakeConstraints { (make) in
            make.top.equalToSuperview().inset(verticalInset)
            make.bottom.equalToSuperview().inset(verticalInset)
            make.leading.equalToSuperview().inset(sideInset)
            make.trailing.equalToSuperview().inset(sideInset)
            make.height.equalTo(0)
        }
        switchView.snp.remakeConstraints { (make) in
            make.trailing.equalToSuperview().inset(sideInset)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(0)
        }
    }
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
