//
//  HomeViewModel.swift
//  AppTemplate — AppRouterDemo
//

import AppStart

final class HomeViewModel: ViewModel {

    let demoCircleId = "circle-demo-001"
    let demoUserId = "user-demo-001"

    /// Home 自己的展示数据（Demo 本地模拟；正式工程在此请求 Home 聚合接口即可）
    private(set) var circleName = ""
    private(set) var memberCount = 0
    private(set) var unreadCount = 0
    private(set) var isJoined = false

    func loadSnapshot() {
        circleName = "跑步打卡圈"
        memberCount = 1286
        unreadCount = 3
        isJoined = true
    }

    var snapshotText: String {
        """
        【Home 快照】
        circle: \(demoCircleId)
        name: \(circleName)
        members: \(memberCount)
        unread: \(unreadCount)
        joined: \(isJoined)
        """
    }
}
