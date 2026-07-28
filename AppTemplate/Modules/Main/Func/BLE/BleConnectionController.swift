//
//  BleConnectionController.swift
//  AppTemplate
//
//  复用 BleSession.activeConnection：状态监听、Notify 接收、写指令。

import Foundation
import CoreBluetooth
import AppStart

// MARK: - Main Class
class BleConnectionController: DefaultViewController {

    private var stateTask: Task<Void, Never>?
    private var notifyTask: Task<Void, Never>?
    private var writeTask: Task<Void, Never>?

    private lazy var stateLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 16)
        label.numberOfLines = 0
        label.text = "未连接"
        return label
    }()

    private lazy var deviceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        return label
    }()

    private lazy var logTextView: UITextView = {
        let view = UITextView()
        view.font = .monospacedSystemFont(ofSize: 12, weight: .regular)
        view.isEditable = false
        view.backgroundColor = UIColor(white: 0.96, alpha: 1)
        view.layer.cornerRadius = 8
        return view
    }()

    private lazy var commandField: UITextField = {
        let field = UITextField()
        field.placeholder = "十六进制指令，如 01 02 03"
        field.borderStyle = .roundedRect
        field.font = .monospacedSystemFont(ofSize: 14, weight: .regular)
        field.autocapitalizationType = .allCharacters
        field.autocorrectionType = .no
        field.text = BlePumpCommand.hexDescription(BlePumpCommand.defaultC0Control())
        return field
    }()

    private lazy var writeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("C0 控制", for: .normal)
        button.addTarget(self, action: #selector(writeButtonTapped), for: .touchUpInside)
        return button
    }()

    private lazy var f0Button: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("F0 鉴权", for: .normal)
        button.addTarget(self, action: #selector(f0ButtonTapped), for: .touchUpInside)
        return button
    }()

    private lazy var disconnectButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("断开连接", for: .normal)
        button.setTitleColor(.systemRed, for: .normal)
        button.addTarget(self, action: #selector(disconnectButtonTapped), for: .touchUpInside)
        return button
    }()

    override func setupLayout() {
        super.setupLayout()
        naviBar.title = "连接控制台"
        view.addSubview(stateLabel)
        view.addSubview(deviceLabel)
        view.addSubview(logTextView)
        view.addSubview(commandField)
        view.addSubview(writeButton)
        view.addSubview(f0Button)
        view.addSubview(disconnectButton)

        stateLabel.snp.makeConstraints { make in
            make.top.equalTo(naviBar.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        deviceLabel.snp.makeConstraints { make in
            make.top.equalTo(stateLabel.snp.bottom).offset(4)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        logTextView.snp.makeConstraints { make in
            make.top.equalTo(deviceLabel.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(220)
        }
        commandField.snp.makeConstraints { make in
            make.top.equalTo(logTextView.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(40)
        }
        writeButton.snp.makeConstraints { make in
            make.top.equalTo(commandField.snp.bottom).offset(12)
            make.leading.equalToSuperview().offset(16)
        }
        f0Button.snp.makeConstraints { make in
            make.centerY.equalTo(writeButton)
            make.leading.equalTo(writeButton.snp.trailing).offset(16)
        }
        disconnectButton.snp.makeConstraints { make in
            make.centerY.equalTo(writeButton)
            make.trailing.equalToSuperview().inset(16)
        }
    }

    override func bindViewModel() {
        super.bindViewModel()
        refreshConnectionUI()
        startObserving()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stateTask?.cancel()
        notifyTask?.cancel()
        writeTask?.cancel()
        stateTask = nil
        notifyTask = nil
        writeTask = nil
    }

    private func refreshConnectionUI() {
        guard let connection = BleSession.shared.activeConnection else {
            stateLabel.text = "无活跃连接"
            stateLabel.textColor = .systemOrange
            deviceLabel.text = "请先在「扫描并连接」页面连接设备"
            writeButton.isEnabled = false
            f0Button.isEnabled = false
            disconnectButton.isEnabled = false
            return
        }

        writeButton.isEnabled = true
        f0Button.isEnabled = true
        disconnectButton.isEnabled = true
        updateCommandFieldForConnection(connection)
        let peripheral = connection.peripheral
        deviceLabel.text = """
        设备：\(peripheral.name ?? "未知")
        产品：\(BleStateFormatter.productDisplayName(for: connection))
        UUID：\(peripheral.identifier.uuidString)
        """
        updateStateLabel(connection.currentState)
    }

    private func startObserving() {
        guard let connection = BleSession.shared.activeConnection else { return }

        stateTask?.cancel()
        stateTask = Task { [weak self] in
            let stream = await connection.states()
            for await state in stream {
                guard !Task.isCancelled else { break }
                await MainActor.run {
                    self?.updateStateLabel(state)
                }
            }
        }

        notifyTask?.cancel()
        notifyTask = Task { [weak self] in
            let stream = await connection.characteristicUpdates()
            for await update in stream {
                guard !Task.isCancelled else { break }
                await MainActor.run {
                    self?.appendLog(
                        "Notify · \(update.characteristic.uuid.uuidString) · \(BleStateFormatter.dataHexDescription(update.data))"
                    )
                }
            }
        }
    }

    private func updateStateLabel(_ state: BlePeripheralState) {
        stateLabel.text = BleStateFormatter.peripheralStateDescription(state)
        switch state {
        case .ready:
            stateLabel.textColor = .systemGreen
            if let connection = BleSession.shared.activeConnection {
                updateCommandFieldForConnection(connection)
                let peripheral = connection.peripheral
                deviceLabel.text = """
                设备：\(peripheral.name ?? "未知")
                产品：\(BleStateFormatter.productDisplayName(for: connection))
                UUID：\(peripheral.identifier.uuidString)
                """
            }
        case .failed, .timedOut:
            stateLabel.textColor = .systemRed
        case .disconnected:
            stateLabel.textColor = .systemOrange
        default:
            stateLabel.textColor = .label
        }
    }

    private func appendLog(_ message: String) {
        let timestamp = Self.logFormatter.string(from: Date())
        let line = "[\(timestamp)] \(message)\n"
        logTextView.text = (logTextView.text ?? "") + line
        let textLength = (logTextView.text as NSString?)?.length ?? 0
        let bottom = NSRange(location: max(textLength - 1, 0), length: 1)
        logTextView.scrollRangeToVisible(bottom)
    }

    @objc private func writeButtonTapped() {
        sendCommand(from: commandField.text)
    }

    @objc private func f0ButtonTapped() {
        sendCommand(data: BlePumpCommand.defaultF0Auth())
    }

    private func sendCommand(from hex: String?) {
        guard let data = parseHex(hex) else {
            ProgressHUD.failed("指令格式错误")
            return
        }
        sendCommand(data: data)
    }

    private func sendCommand(data: Data) {
        guard let connection = BleSession.shared.activeConnection else {
            ProgressHUD.failed("无活跃连接")
            return
        }

        writeTask?.cancel()
        writeTask = Task { [weak self] in
            do {
                try await connection.write(data)
                await MainActor.run {
                    self?.appendLog("Write · \(BleStateFormatter.dataHexDescription(data))")
                    ProgressHUD.succeed("发送成功")
                }
            } catch {
                await MainActor.run {
                    self?.appendLog("Write Failed · \(error.localizedDescription)")
                    ProgressHUD.failed(error.localizedDescription)
                }
            }
        }
    }

    private func isPumpConnection(_ connection: BlePeripheralConnection) -> Bool {
        if case .ready(let info) = connection.currentState {
            return info.service.uuid == BleGattUUID.transportService
        }
        return BleStateFormatter.productDisplayName(for: connection) == "吸奶器"
    }

    private func updateCommandFieldForConnection(_ connection: BlePeripheralConnection) {
        let isPump = isPumpConnection(connection)
        f0Button.isHidden = !isPump
        if isPump {
            commandField.text = BlePumpCommand.hexDescription(BlePumpCommand.defaultC0Control())
            commandField.placeholder = "C0 控制帧（可编辑）"
            writeButton.setTitle("C0 控制", for: .normal)
        } else {
            commandField.placeholder = "十六进制指令，如 01 02 03"
            commandField.text = "01 02 03"
            writeButton.setTitle("发送写指令", for: .normal)
        }
    }

    @objc private func disconnectButtonTapped() {
        guard let connection = BleSession.shared.activeConnection else { return }
        connection.disconnect()
        BleSession.shared.activeConnection = nil
        appendLog("用户主动断开")
        refreshConnectionUI()
    }

    private func parseHex(_ text: String?) -> Data? {
        guard let text else { return nil }
        let parts = text
            .replacingOccurrences(of: ",", with: " ")
            .split(whereSeparator: \.isWhitespace)
        guard !parts.isEmpty else { return nil }
        var bytes: [UInt8] = []
        for part in parts {
            guard let value = UInt8(part, radix: 16) else { return nil }
            bytes.append(value)
        }
        return Data(bytes)
    }

    private static let logFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter
    }()
}
