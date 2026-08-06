//
//  AppRouter.swift
//  AppTemplate — AppRouterDemo
//
//  类型安全路由表：按 Route 类型注册 builder。
//

import UIKit

final class AppRouter {

    static let shared = AppRouter()

    private var builders: [ObjectIdentifier: (Any) -> UIViewController?] = [:]

    private init() {}

    func map<R: RouteKey>(_ type: R.Type, builder: @escaping (R) -> UIViewController?) {
        builders[ObjectIdentifier(type)] = { any in
            guard let route = any as? R else { return nil }
            return builder(route)
        }
    }

    func viewController<R: RouteKey>(for route: R) -> UIViewController? {
        builders[ObjectIdentifier(R.self)]?(route)
    }
}
