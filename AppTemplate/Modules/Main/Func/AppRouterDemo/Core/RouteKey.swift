//
//  RouteKey.swift
//  AppTemplate — AppRouterDemo
//

import Foundation
import ObjectiveC

/// 路由键标记。各业务定义自己的 `enum XxxRoute: RouteKey`。
protocol RouteKey {}

/// 业务模块向 `AppRouter` 注册页面工厂。
protocol RouteRegistering: AnyObject {
    init()
    func register(into router: AppRouter)
}

/// Feature 继承并 override `register(into:)`，由 `AppRouterBootstrap.register(_:)` 或 `registerAll()` 登记。
///
/// 继承 `NSObject` 仅为可选的运行时扫类（`RouteRegisterDiscovery`）；手动登记不依赖此项。
class RouteRegister: NSObject, RouteRegistering {

    required override init() {
        super.init()
    }

    func register(into router: AppRouter) {
        assertionFailure("\(type(of: self)) 需 override register(into:)")
    }
}

// MARK: - 运行时发现

enum RouteRegisterDiscovery {

    private static let base = RouteRegister.self
    /// 主 App `.app` 包路径。Debug 下业务类在 `AppTemplate.debug.dylib` 内，也在此路径下。
    private static let bundlePath = Bundle.main.bundlePath

    /// 收集主 App bundle 内所有 `RouteRegister` 子类并实例化（供 `registerAll()` 使用）。
    static func allRegisters() -> [RouteRegister] {
        // 1. 取当前进程已加载类的数量（含系统框架 + 所有 Pod，数量级通常 1~5 万）
        let n = objc_getClassList(nil, 0)
        guard n > 0 else { return [] }

        let buffer = UnsafeMutablePointer<AnyClass>.allocate(capacity: Int(n))
        defer { buffer.deallocate() }
        let count = Int(objc_getClassList(AutoreleasingUnsafeMutablePointer(buffer), n))

        return (0..<count).compactMap { index -> RouteRegister? in
            let cls: AnyClass = buffer[index]

            // 2. 跳过元类，避免对 Class 的 Class 做 superclass 遍历
            guard !class_isMetaClass(cls) else { return nil }

            // 3. 只保留主 App bundle 内的类（主二进制 + .debug.dylib 等）
            //    不能只用 executablePath：Debug dylib 路径与主二进制不同，会扫不到 Register
            //    也不能不滤：对系统类做 superclass 遍历可能 EXC_BREAKPOINT
            guard let image = class_getImageName(cls).map({ String(cString: $0) }),
                  image.hasPrefix(bundlePath) else { return nil }

            // 4. 必须是 RouteRegister 的直接/间接子类
            guard cls != base, isSubclass(cls, of: base),
                  let type = cls as? RouteRegister.Type else { return nil }

            return type.init()
        }
    }

    private static func isSubclass(_ cls: AnyClass, of base: AnyClass) -> Bool {
        var current: AnyClass? = class_getSuperclass(cls)
        while let ancestor = current {
            if ancestor == base { return true }
            current = class_getSuperclass(ancestor)
        }
        return false
    }
}
