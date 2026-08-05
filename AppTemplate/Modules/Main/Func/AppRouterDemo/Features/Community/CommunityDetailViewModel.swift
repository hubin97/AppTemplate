//
//  CommunityDetailViewModel.swift
//  AppTemplate — AppRouterDemo
//

import AppStart

final class CommunityDetailViewModel: ViewModel {

    let circleId: String
    let isOfficial: Bool

    init(circleId: String, isOfficial: Bool) {
        self.circleId = circleId
        self.isOfficial = isOfficial
        super.init()
    }

    required init() {
        self.circleId = ""
        self.isOfficial = false
        super.init()
    }
}
