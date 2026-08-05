//
//  ProfileRoute.swift
//  AppTemplate — AppRouterDemo
//
//  路由意图 + 注册：Home 可依赖 ProfileRoute。
//

import AppStart
import UIKit

enum ProfileRoute: RouteKey {
    case detail(userId: String)
}

extension ProfileRoute: SceneProvider {
    var getSegue: UIViewController? {
        AppRouter.shared.viewController(for: self)
    }
}

final class ProfileRouteRegister: RouteRegister {

    override func register(into router: AppRouter) {
        router.map(ProfileRoute.self) { route in
            switch route {
            case .detail(let userId):
                return ProfileDetailDemoController(
                    viewModel: ProfileDetailViewModel(userId: userId)
                )
            }
        }
    }
}
