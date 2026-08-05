//
//  CommunityRoute.swift
//  AppTemplate — AppRouterDemo
//
//  路由意图 + 注册：Home 可依赖 CommunityRoute。
//

import AppStart
import UIKit

enum CommunityRoute: RouteKey {
    case detail(circleId: String, isOfficial: Bool)
    case joinScan(fromHome: Bool)
}

extension CommunityRoute: SceneProvider {
    var getSegue: UIViewController? {
        AppRouter.shared.viewController(for: self)
    }
}

final class CommunityRouteRegister: RouteRegister {

    override func register(into router: AppRouter) {
        router.map(CommunityRoute.self) { route in
            switch route {
            case .detail(let circleId, let isOfficial):
                return CommunityDetailDemoController(
                    viewModel: CommunityDetailViewModel(circleId: circleId, isOfficial: isOfficial)
                )
            case .joinScan(let fromHome):
                return CommunityJoinScanDemoController(
                    viewModel: CommunityJoinScanViewModel(fromHome: fromHome)
                )
            }
        }
    }
}
