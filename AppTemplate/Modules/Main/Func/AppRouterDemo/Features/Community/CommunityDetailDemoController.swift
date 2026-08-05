//
//  CommunityDetailDemoController.swift
//  AppTemplate — AppRouterDemo（Community 内部页，Home 不得直接引用）
//

import AppStart
import SnapKit
import UIKit

final class CommunityDetailDemoController: DefaultViewController, ViewModelProvider {
    typealias ViewModelType = CommunityDetailViewModel

    override func setupLayout() {
        super.setupLayout()
        naviBar.title = vm.isOfficial ? "官方圈子" : "圈子详情"

        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = .label
        label.text = """
        AppRouterDemo 社区详情
        （由 CommunityRouteRegister 创建，Home 未引用本类）

        circleId: \(vm.circleId)
        official: \(vm.isOfficial)
        """
        view.addSubview(label)
        label.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(24)
            make.centerY.equalToSuperview()
        }
    }
}
