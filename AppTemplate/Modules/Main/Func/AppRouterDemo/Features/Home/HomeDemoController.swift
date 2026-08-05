//
//  HomeDemoController.swift
//  AppTemplate — AppRouterDemo
//
//  Home 只依赖：HomeViewModel + CommunityRoute / ProfileRoute + Navigator
//  不依赖：Community 的 VC / ViewModel 实现类
//

import AppStart
import SnapKit
import UIKit

final class HomeDemoController: DefaultViewController, ViewModelProvider {
    typealias ViewModelType = HomeViewModel

    private let statusLabel = UILabel()
    private let openButton = UIButton(type: .system)
    private let scanButton = UIButton(type: .system)
    private let profileButton = UIButton(type: .system)

    override func setupLayout() {
        super.setupLayout()
        naviBar.title = "分域路由"

        statusLabel.numberOfLines = 0
        statusLabel.font = .monospacedSystemFont(ofSize: 14, weight: .regular)
        statusLabel.textColor = .label
        statusLabel.text = "loading…"

        openButton.setTitle("打开圈子详情", for: .normal)
        openButton.addTarget(self, action: #selector(openCommunityDetail), for: .touchUpInside)

        scanButton.setTitle("扫码加入圈子", for: .normal)
        scanButton.addTarget(self, action: #selector(openJoinScan), for: .touchUpInside)

        profileButton.setTitle("打开个人主页", for: .normal)
        profileButton.addTarget(self, action: #selector(openProfile), for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [statusLabel, openButton, scanButton, profileButton])
        stack.axis = .vertical
        stack.spacing = 20
        view.addSubview(stack)
        stack.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(24)
            make.centerY.equalToSuperview()
        }
    }

    override func bindViewModel() {
        super.bindViewModel()
        vm.loadSnapshot()
        statusLabel.text = vm.snapshotText
    }

    // MARK: - Route → Navigator.show(provider:)

    @objc private func openCommunityDetail() {
        navigator.show(
            provider: CommunityRoute.detail(circleId: vm.demoCircleId, isOfficial: false),
            sender: self
        )
    }

    @objc private func openJoinScan() {
        navigator.show(
            provider: CommunityRoute.joinScan(fromHome: true),
            sender: self
        )
    }

    @objc private func openProfile() {
        navigator.show(
            provider: ProfileRoute.detail(userId: vm.demoUserId),
            sender: self
        )
    }
}
