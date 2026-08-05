//
//  CommunityJoinScanDemoController.swift
//  AppTemplate — AppRouterDemo（Community 内部页，Home 不得直接引用）
//

import AppStart
import SnapKit
import UIKit

final class CommunityJoinScanDemoController: DefaultViewController, ViewModelProvider {
    typealias ViewModelType = CommunityJoinScanViewModel

    override func setupLayout() {
        super.setupLayout()
        naviBar.title = "扫码加入圈子"

        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .label
        label.text = "Join Scan demo (fromHome=\(vm.fromHome))"
        view.addSubview(label)
        label.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
}
