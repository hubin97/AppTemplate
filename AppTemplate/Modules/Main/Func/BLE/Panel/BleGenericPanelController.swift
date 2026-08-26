//
//  BleGenericPanelController.swift
//  AppTemplate
//
//  非 Pump 品类面板占位，后续按品类扩展。

import Foundation

class BleGenericPanelController: DefaultViewController {

    private let device: BleBoundDevice?

    init(device: BleBoundDevice?) {
        self.device = device
        super.init(viewModel: nil)
    }

    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private lazy var detailLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = BleUITokens.textSecondary
        label.numberOfLines = 0
        return label
    }()

    override func setupLayout() {
        super.setupLayout()
        naviBar.title = device?.displayName ?? "设备面板"
        view.backgroundColor = BleUITokens.pageBackground
        view.addSubview(detailLabel)
        detailLabel.snp.makeConstraints { make in
            make.top.equalTo(naviBar.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(16)
        }

        guard let device else {
            detailLabel.text = "找不到这台设备，可能已经被移除"
            return
        }
        detailLabel.text = """
        \(device.category.displayName) 的控制面板还在路上。
        现在可以先在「连接控制台」里看状态和发指令。

        MAC  \(device.mac ?? "—")
        UUID  \(device.uuid)
        """
    }
}
