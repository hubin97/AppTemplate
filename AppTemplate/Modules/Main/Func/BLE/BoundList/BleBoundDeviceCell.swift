//
//  BleBoundDeviceCell.swift
//  AppTemplate
//
//  已绑定设备卡：相对发现页补充品类、握手、绑定时间等细节。

import UIKit
import SnapKit

final class BleBoundDeviceCell: TableViewCell {

    private let card = UIView()
    private let nameLabel = UILabel()
    private let categoryBadge = UILabel()
    private let detailLabel = UILabel()

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

        categoryBadge.font = .systemFont(ofSize: 11, weight: .medium)
        categoryBadge.textColor = BleUITokens.momFill
        categoryBadge.backgroundColor = BleUITokens.momFill.withAlphaComponent(0.08)
        categoryBadge.textAlignment = .center
        categoryBadge.layer.cornerRadius = 6
        categoryBadge.clipsToBounds = true

        detailLabel.font = .systemFont(ofSize: 12)
        detailLabel.textColor = BleUITokens.textSecondary
        detailLabel.numberOfLines = 0

        let header = UIStackView(arrangedSubviews: [nameLabel, categoryBadge])
        header.axis = .horizontal
        header.alignment = .center
        header.spacing = 8

        let stack = UIStackView(arrangedSubviews: [header, detailLabel])
        stack.axis = .vertical
        stack.spacing = 6
        stack.alignment = .fill

        contentView.addSubview(card)
        card.addSubview(stack)

        card.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 6, left: BleUITokens.space4, bottom: 6, right: BleUITokens.space4))
        }
        stack.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(12)
        }
        categoryBadge.snp.makeConstraints { make in
            make.height.equalTo(22)
            make.width.greaterThanOrEqualTo(52)
        }
        nameLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        categoryBadge.setContentHuggingPriority(.required, for: .horizontal)
    }

    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(_ device: BleBoundDevice) {
        nameLabel.text = device.displayName
        categoryBadge.text = " \(device.category.displayName) "
        let typeText = device.deviceType.map { String(format: "0x%02X", $0) } ?? "—"
        let rssiText = device.lastRSSI.map { "\($0) dBm" } ?? "—"
        let bound = Self.dateFormatter.string(from: device.boundAt)
        detailLabel.text = """
        MAC  \(device.mac ?? "—")    UUID  \(device.uuid)
        型号  \(typeText)    信号  \(rssiText)
        productKey  \(device.productKey ?? "—")    deviceKey  \(device.deviceKey ?? "—")
        连接  \(device.connectionDisplayName)    添加于  \(bound)
        """
    }

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年M月d日 HH:mm"
        return formatter
    }()
}
