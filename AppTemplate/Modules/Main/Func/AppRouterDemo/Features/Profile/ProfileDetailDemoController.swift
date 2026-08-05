//
//  ProfileDetailDemoController.swift
//  AppTemplate — AppRouterDemo（Profile 内部页，Home 不得直接引用）
//

import AppStart
import SnapKit
import UIKit

final class ProfileDetailDemoController: DefaultViewController, ViewModelProvider {
    typealias ViewModelType = ProfileDetailViewModel

    override func setupLayout() {
        super.setupLayout()
        naviBar.title = "个人主页"

        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = .label
        label.text = """
        AppRouterDemo 个人主页
        （由 ProfileRouteRegister 自动注册，Home 未引用本类）

        userId: \(vm.userId)
        name: \(vm.displayName)
        """
        view.addSubview(label)
        label.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(24)
            make.centerY.equalToSuperview()
        }
    }
}
