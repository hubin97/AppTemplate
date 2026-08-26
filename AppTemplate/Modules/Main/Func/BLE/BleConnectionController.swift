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
    private var analyticsTask: Task<Void, Never>?
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

    private lazy var handshakeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("配网握手", for: .normal)
        button.addTarget(self, action: #selector(handshakeButtonTapped), for: .touchUpInside)
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
        view.addSubview(handshakeButton)
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
            make.top.equalTo(writeButton.snp.bottom).offset(8)
            make.leading.equalToSuperview().offset(16)
        }
        handshakeButton.snp.makeConstraints { make in
            make.centerY.equalTo(f0Button)
            make.leading.equalTo(f0Button.snp.trailing).offset(16)
        }
        disconnectButton.snp.makeConstraints { make in
            make.centerY.equalTo(f0Button)
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
        analyticsTask?.cancel()
        writeTask?.cancel()
        stateTask = nil
        notifyTask = nil
        analyticsTask = nil
        writeTask = nil
    }

    private func refreshConnectionUI() {
        guard let connection = BleSession.shared.activeConnection else {
            stateLabel.text = "无活跃连接"
            stateLabel.textColor = .systemOrange
            deviceLabel.text = "请先在「扫描并连接」页面连接设备"
            writeButton.isEnabled = false
            f0Button.isEnabled = false
            handshakeButton.isEnabled = false
            disconnectButton.isEnabled = false
            return
        }

        writeButton.isEnabled = true
        f0Button.isEnabled = true
        handshakeButton.isEnabled = true
        disconnectButton.isEnabled = true
        updateCommandFieldForConnection(connection)
        let peripheral = connection.peripheral
        let connectionCount = BleSession.shared.activeConnections.count
        deviceLabel.text = """
        设备：\(peripheral.name ?? "未知")
        产品：\(BleStateFormatter.productDisplayName(for: connection))
        活跃连接数：\(connectionCount)
        UUID：\(peripheral.identifier.uuidString)
        GATT：\(gattSummary(for: connection))
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
                    let device = update.peripheral.name ?? update.peripheral.identifier.uuidString
                    if let parsed = BlePumpTrace.describeReceive(update.data, device: device) {
                        self?.appendLog(parsed)
                    }
                }
            }
        }

        analyticsTask?.cancel()
        analyticsTask = Task { [weak self] in
            let stream = await connection.characteristicUpdates(matching: BleGattUUID.secondary.notifyUUID)
            for await update in stream {
                guard !Task.isCancelled else { break }
                let event = BlePumpAnalyticsParser.parse(update.data)
                await MainActor.run {
                    self?.appendLog("Analytics · \(event.hex)")
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
                let connectionCount = BleSession.shared.activeConnections.count
                deviceLabel.text = """
                设备：\(peripheral.name ?? "未知")
                产品：\(BleStateFormatter.productDisplayName(for: connection))
                活跃连接数：\(connectionCount)
                UUID：\(peripheral.identifier.uuidString)
                GATT：\(gattSummary(for: connection))
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
        LogM.tag("Ble/Pump").debug(message)
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

    @objc private func handshakeButtonTapped() {
        guard let connection = BleSession.shared.activeConnection else {
            ProgressHUD.failed("无活跃连接")
            return
        }
        guard isPumpConnection(connection) else {
            ProgressHUD.failed("仅 Pump 设备支持配网握手 Demo")
            return
        }

        writeTask?.cancel()
        writeTask = Task { [weak self] in
            do {
                let result = try await BleProvisionHandshake.run(
                    on: connection,
                    log: { message in
                        Task { @MainActor in
                            self?.appendLog(message)
                        }
                    }
                )
                await MainActor.run {
                    var detail = "握手完成"
                    if let profile = result.profile {
                        detail += " · \(profile.logName)"
                    }
                    if let key = result.f0Info?.encryptionKey {
                        detail += " · key=0x\(String(format: "%02X", key))"
                    }
                    if result.tripletInfo?.isValid == true {
                        detail += " · 三元组 OK"
                    }
                    self?.appendLog(detail)
                    ProgressHUD.succeed("握手完成")
                }
            } catch {
                await MainActor.run {
                    self?.appendLog("握手失败 · \(error.localizedDescription)")
                    ProgressHUD.failed(error.localizedDescription)
                }
            }
        }
    }

    private func gattSummary(for connection: BlePeripheralConnection) -> String {
        if case .ready(let info) = connection.currentState {
            return info.service.uuid.uuidString
        }
        return "—"
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
            let device = connection.peripheral.name ?? connection.peripheral.identifier.uuidString
            await MainActor.run {
                self?.appendLog("Write · \(BleStateFormatter.dataHexDescription(data))")
                if let parsed = BlePumpTrace.describeSend(data, device: device) {
                    self?.appendLog(parsed)
                }
            }
            do {
                try await connection.write(data)
                await MainActor.run {
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
        if BleStateFormatter.productDisplayName(for: connection) == "Pump" {
            return true
        }
        if case .ready(let info) = connection.currentState {
            return BleUUID.matches(info.service.uuid, BleGattUUID.primary.serviceUUID)
                || BleUUID.matches(info.service.uuid, BleGattUUID.extended.serviceUUID)
        }
        return false
    }

    private func updateCommandFieldForConnection(_ connection: BlePeripheralConnection) {
        let isPump = isPumpConnection(connection)
        f0Button.isHidden = !isPump
        handshakeButton.isHidden = !isPump
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
