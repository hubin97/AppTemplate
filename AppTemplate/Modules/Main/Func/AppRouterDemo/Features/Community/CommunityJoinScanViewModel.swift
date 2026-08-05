//
//  CommunityJoinScanViewModel.swift
//  AppTemplate — AppRouterDemo
//

import AppStart

final class CommunityJoinScanViewModel: ViewModel {

    let fromHome: Bool

    init(fromHome: Bool) {
        self.fromHome = fromHome
        super.init()
    }

    required init() {
        self.fromHome = false
        super.init()
    }
}
