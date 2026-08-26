//
//  BleBoundDeviceCell.swift
//  AppTemplate
//
//  已绑定设备卡：名称 + 右上角品类；其余字段逐行展示。

import UIKit
import SnapKit

final class BleBoundDeviceCell: TableViewCell {

    private let card = UIView()
    private let nameLabel = UILabel()
    private let categoryBadge = UILabel()
    private let connectionRow = UIStackView()
    private let connectionLabel = UILabel()
    private let rssiBadge = UILabel()
    private let macLabel = UILabel()
    private let uuidLabel = UILabel()
    private let typeLabel = UILabel()
    private let boundLabel = UILabel()

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

        categoryBadge.font = .systemFont(ofSize: 11, weight: .medium)
        categoryBadge.textColor = BleUITokens.momFill
        categoryBadge.backgroundColor = BleUITokens.momFill.withAlphaComponent(0.08)
        categoryBadge.textAlignment = .center
        categoryBadge.layer.cornerRadius = BleUITokens.radiusBadge
        categoryBadge.clipsToBounds = true
        categoryBadge.setContentHuggingPriority(.required, for: .horizontal)
        categoryBadge.setContentCompressionResistancePriority(.required, for: .horizontal)

        connectionLabel.font = .systemFont(ofSize: 12, weight: .regular)
        connectionLabel.textColor = BleUITokens.textSecondary
        connectionLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        connectionLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        rssiBadge.font = .systemFont(ofSize: 12, weight: .medium)
        rssiBadge.textAlignment = .center
        rssiBadge.layer.cornerRadius = BleUITokens.radiusBadge
        rssiBadge.clipsToBounds = true
        rssiBadge.setContentHuggingPriority(.required, for: .horizontal)
        rssiBadge.setContentCompressionResistancePriority(.required, for: .horizontal)

        macLabel.font = .monospacedSystemFont(ofSize: 12, weight: .regular)
        macLabel.textColor = BleUITokens.textSecondary

        uuidLabel.font = .monospacedSystemFont(ofSize: 12, weight: .regular)
        uuidLabel.textColor = BleUITokens.textTertiary

        typeLabel.font = .systemFont(ofSize: 12, weight: .regular)
        typeLabel.textColor = BleUITokens.textSecondary

        boundLabel.font = .systemFont(ofSize: 12, weight: .regular)
        boundLabel.textColor = BleUITokens.textTertiary

        let header = UIStackView(arrangedSubviews: [nameLabel, categoryBadge])
        header.axis = .horizontal
        header.alignment = .center
        header.spacing = BleUITokens.space2
        header.distribution = .fill

        connectionRow.axis = .horizontal
        connectionRow.alignment = .center
        connectionRow.spacing = BleUITokens.space2
        connectionRow.distribution = .fill
        connectionRow.addArrangedSubview(connectionLabel)
        connectionRow.addArrangedSubview(rssiBadge)

        let stack = UIStackView(arrangedSubviews: [
            header,
            connectionRow,
            macLabel,
            uuidLabel,
            typeLabel,
            boundLabel
        ])
        stack.axis = .vertical
        stack.alignment = .fill
        stack.spacing = BleUITokens.space2

        contentView.addSubview(card)
        card.addSubview(stack)

        card.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(horizontal: BleUITokens.space2, vertical: BleUITokens.space1))
        }
        stack.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(12)
        }
        categoryBadge.snp.makeConstraints { make in
            make.height.equalTo(24)
            make.width.greaterThanOrEqualTo(56)
        }
        rssiBadge.snp.makeConstraints { make in
            make.height.equalTo(24)
            make.width.greaterThanOrEqualTo(72)
        }
    }

    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(_ device: BleBoundDevice) {
        nameLabel.text = device.displayName
        categoryBadge.text = " \(device.category.displayName) "
        connectionLabel.text = "连接  \(device.connectionDisplayName)"

        if device.isLiveConnected, let rssi = device.lastRSSI {
            rssiBadge.isHidden = false
            rssiBadge.text = "\(rssi) dBm"
            applyRSSIStyle(rssi)
        } else {
            rssiBadge.isHidden = true
        }

        macLabel.text = "MAC  \(device.mac ?? "—")"
        uuidLabel.text = "UUID  \(device.uuid)"
        let typeText = device.deviceType.map { String(format: "0x%02X", $0) } ?? "—"
        typeLabel.text = "型号  \(typeText)"
        boundLabel.text = "添加于  \(Self.dateFormatter.string(from: device.boundAt))"
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

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年M月d日 HH:mm"
        return formatter
    }()
}
