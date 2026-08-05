//
//  ProfileDetailViewModel.swift
//  AppTemplate — AppRouterDemo
//

import AppStart

final class ProfileDetailViewModel: ViewModel {

    let userId: String

    init(userId: String) {
        self.userId = userId
        super.init()
    }

    required init() {
        self.userId = ""
        super.init()
    }

    var displayName: String { "用户 \(userId)" }
}
