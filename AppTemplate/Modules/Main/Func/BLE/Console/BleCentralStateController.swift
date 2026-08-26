//
//  BleCentralStateController.swift
//  AppTemplate
//
//  监听 CBCentralManager 蓝牙开关状态。

import Foundation
import CoreBluetooth
import AppStart

// MARK: - Main Class
class BleCentralStateController: DefaultViewController {

    private var observationTask: Task<Void, Never>?

    private lazy var stateLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 20)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = "等待状态..."
        return label
    }()

    private lazy var hintLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.textAlignment = .center
        label.text = """
        let stream = await BleSession.shared.central.centralStates()
        for await state in stream {
            // 监听蓝牙开关状态
        }
        """
        return label
    }()

    override func setupLayout() {
        super.setupLayout()
        naviBar.title = "蓝牙状态"
        view.addSubview(stateLabel)
        view.addSubview(hintLabel)

        stateLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-40)
            make.leading.trailing.equalToSuperview().inset(24)
        }
        hintLabel.snp.makeConstraints { make in
            make.top.equalTo(stateLabel.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(24)
        }
    }

    override func bindViewModel() {
        super.bindViewModel()
        startObserving()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        observationTask?.cancel()
        observationTask = nil
    }

    private func startObserving() {
        observationTask?.cancel()
        observationTask = Task { [weak self] in
            let stream = await BleSession.shared.central.centralStates()
            for await state in stream {
                guard !Task.isCancelled else { break }
                await MainActor.run {
                    self?.stateLabel.text = BleStateFormatter.centralStateDescription(state)
                    self?.stateLabel.textColor = state == .poweredOn ? .systemGreen : .systemOrange
                }
            }
        }
    }
}
