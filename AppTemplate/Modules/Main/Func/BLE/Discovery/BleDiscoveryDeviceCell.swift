//
//  BleDiscoveryDeviceCell.swift
//  AppTemplate
//
//  发现列表 cell：从左到右为外设名、MAC、UUID、信号强度。

import UIKit
import SnapKit

final class BleDiscoveryDeviceCell: TableViewCell {

    private let card = UIView()
    private let nameLabel = UILabel()
    private let macLabel = UILabel()
    private let uuidLabel = UILabel()
    private let rssiBadge = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        accessoryView = nil
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        card.backgroundColor = BleUITokens.cardBackground
        card.layer.cornerRadius = BleUITokens.radiusCard
        card.layer.borderWidth = 0.5
        card.layer.borderColor = BleUITokens.border.cgColor

        nameLabel.font = .systemFont(ofSize: 16, weight: .medium)
        nameLabel.textColor = BleUITokens.textPrimary
        nameLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        nameLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        macLabel.font = .monospacedSystemFont(ofSize: 12, weight: .regular)
        macLabel.textColor = BleUITokens.textSecondary
        macLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)

        uuidLabel.font = .monospacedSystemFont(ofSize: 12, weight: .regular)
        uuidLabel.textColor = BleUITokens.textTertiary
        uuidLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)

        rssiBadge.font = .systemFont(ofSize: 12, weight: .medium)
        rssiBadge.textAlignment = .center
        rssiBadge.layer.cornerRadius = BleUITokens.radiusBadge
        rssiBadge.clipsToBounds = true
        rssiBadge.setContentHuggingPriority(.required, for: .horizontal)
        rssiBadge.setContentCompressionResistancePriority(.required, for: .horizontal)

        let row = UIStackView(arrangedSubviews: [nameLabel, macLabel, uuidLabel, rssiBadge])
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = BleUITokens.space2
        row.distribution = .fill

        contentView.addSubview(card)
        card.addSubview(row)

        card.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(horizontal: BleUITokens.space2, vertical: BleUITokens.space1))
        }
        row.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12))
        }
        rssiBadge.snp.makeConstraints { make in
            make.width.greaterThanOrEqualTo(56)
            make.height.equalTo(24)
        }
    }

    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(name: String, mac: String, uuid: String, rssi: Int) {
        nameLabel.text = name
        macLabel.text = mac
        uuidLabel.text = Self.shortUUID(uuid)
        rssiBadge.text = "\(rssi) dBm"
        applyRSSIStyle(rssi)
    }

    private func applyRSSIStyle(_ rssi: Int) {
        if rssi >= -50 {
            rssiBadge.backgroundColor = BleUITokens.success.withAlphaComponent(0.15)
            rssiBadge.textColor = BleUITokens.success
        } else if rssi >= -70 {
            rssiBadge.backgroundColor = BleUITokens.warning.withAlphaComponent(0.18)
            rssiBadge.textColor = BleUITokens.warning
        } else {
            rssiBadge.backgroundColor = BleUITokens.border
            rssiBadge.textColor = BleUITokens.textSecondary
        }
    }

    private static func shortUUID(_ uuid: String) -> String {
        let compact = uuid.replacingOccurrences(of: "-", with: "")
        guard compact.count >= 8 else { return uuid }
        return String(compact.suffix(8))
    }
}
