//
//  BGTaskHandler.swift
//  Momcozy
//
//  Created by hubin.h on 2024/7/18.
//  Copyright © 2025 Hubin_Huang. All rights reserved.

import Foundation
import BackgroundTasks

/// 后台任务调度与保活。状态自管；只有 `UIApplication` 的 begin/end 必须在主线程。
/// `enabled` / `taskHandler` 用锁，`backgroundTask` 在 MainActor；编译器看不到这层约束。
final class BGTaskManager: @unchecked Sendable {
    static let shared = BGTaskManager()

    /// 是否启用此后台任务
    var isEnable: Bool {
        get { withState { enabled } }
        set { withState { enabled = newValue } }
    }

    private let stateLock = NSLock()
    private var enabled = false
    private var taskHandler: (@Sendable () -> Void)?

    /// `UIApplication` 的 token，只在主线程读写。
    @MainActor
    private var backgroundTask: UIBackgroundTaskIdentifier = .invalid

    private init() {
        setupAppAvailableListen()
    }

    // MARK: - Public Methods

    /// 设置后台任务和业务处理逻辑
    ///
    /// - Parameter handler: 业务处理逻辑闭包
    func setupBackgroundTask(handler: (@Sendable () -> Void)? = nil) {
        withState { taskHandler = handler }
        registerBackgroundTasks()
        scheduleBackgroundTask()
    }

    /// 开始后台任务
    @MainActor
    private func startBackgroundTask() {
        if backgroundTask == .invalid {
            LogM.debug("开始后台任务")
            backgroundTask = UIApplication.shared.beginBackgroundTask(withName: "BackgroundTask") {
                Task { @MainActor in
                    BGTaskManager.shared.endBackgroundTask()
                }
            }
        }
    }

    /// 结束后台任务
    @MainActor
    private func endBackgroundTask() {
        if backgroundTask != .invalid {
            LogM.debug("结束后台任务")
            UIApplication.shared.endBackgroundTask(backgroundTask)
            backgroundTask = .invalid
        }
    }
}

// MARK: - private mothods
extension BGTaskManager {

    private func withState<T>(_ body: () -> T) -> T {
        stateLock.lock()
        defer { stateLock.unlock() }
        return body()
    }

    private func setupAppAvailableListen() {
        NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: .main) { _ in
            guard BGTaskManager.shared.isEnable else { return }
            Task { @MainActor in
                BGTaskManager.shared.endBackgroundTask()
            }
        }
        NotificationCenter.default.addObserver(forName: UIApplication.didEnterBackgroundNotification, object: nil, queue: .main) { _ in
            guard BGTaskManager.shared.isEnable else { return }
            Task { @MainActor in
                BGTaskManager.shared.startBackgroundTask()
            }
        }
    }
    
    /// 注册后台任务
    private func registerBackgroundTasks() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.example.app.keepAlive", using: nil) { task in
            guard let processingTask = task as? BGProcessingTask else { return }
            BGTaskManager.shared.handleBackgroundTask(task: processingTask)
        }
    }

    /// 调度后台任务
    private func scheduleBackgroundTask() {
        let request = BGProcessingTaskRequest(identifier: "com.example.app.keepAlive")
        // 不需要网络连接
        request.requiresNetworkConnectivity = true
        // 不需要外部电源
        request.requiresExternalPower = false

        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            LogM.debug("启用后台任务失败: \(error.localizedDescription)")
        }
    }

    /// 处理后台任务
    ///
    /// - Parameter task: 后台任务对象
    private func handleBackgroundTask(task: BGProcessingTask) {
        scheduleBackgroundTask() // 调度下次任务

        // 确保后台任务能够继续运行
        Task { @MainActor in
            BGTaskManager.shared.startBackgroundTask()
        }

        task.expirationHandler = {
            Task { @MainActor in
                BGTaskManager.shared.endBackgroundTask()
            }
        }

        // 执行传入的业务处理逻辑
        let handler = withState { taskHandler }
        handler?()

        task.setTaskCompleted(success: true)
    }
}
