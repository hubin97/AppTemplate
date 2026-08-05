//
//  AppRouterBootstrap.swift
//  AppTemplate — AppRouterDemo
//

import Foundation

enum AppRouterBootstrap {

    private static var didRegister = false

    /// 显式登记；整进程幂等，重复调用无效。
    static func register(_ types: [RouteRegister.Type]) {
        guard !didRegister else { return }
        didRegister = true
        types.forEach { $0.init().register(into: AppRouter.shared) }
    }

    /// 扫类登记全部 `RouteRegister` 子类（见 `RouteRegisterDiscovery`）；与 `register(_:)` 二选一。
    static func registerAll() {
        guard !didRegister else { return }
        didRegister = true
        RouteRegisterDiscovery.allRegisters().forEach {
            $0.register(into: AppRouter.shared)
        }
    }

    #if DEBUG
    static func resetForTests() {
        didRegister = false
        AppRouter.shared.resetForTests()
    }
    #endif
}
