//
//  LTMJRefreshDataProvider.swift
//  Momcozy
//
//  Created by hubin.h on 2024/6/20.
//  Copyright © 2025 Hubin_Huang. All rights reserved.

import Foundation
import PromiseKit
import MJRefresh
import RxRelay

// MARK: -
extension MJRefreshComponent {
    
    /// 多语言设置
    func setupLocalizedStrings() {
        if let header = self as? MJRefreshNormalHeader {
            header.setTitle(RLocalizable.mj_header_refresh.key.localized, for: .idle)
            header.setTitle(RLocalizable.mj_header_release.key.localized, for: .pulling)
            header.setTitle(RLocalizable.mj_header_loading.key.localized, for: .refreshing)
            
            header.lastUpdatedTimeText = { lastUpdatedTime in
                guard let lastUpdatedTime = lastUpdatedTime else {
                    return RLocalizable.mj_header_norecord.key.localized
                }
                
                let calendar = Calendar.current
                if calendar.isDateInToday(lastUpdatedTime) {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "HH:mm"
                    let time = dateFormatter.string(from: lastUpdatedTime)
                    return String(format: "%@: %@ %@", RLocalizable.mj_header_lastupdate.key.localized, RLocalizable.mj_header_today.key.localized, time)
                } else {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = LocalizedUtils.dateFormat_YMD_HM
                    let time = dateFormatter.string(from: lastUpdatedTime)
                    return String(format: "%@: %@", RLocalizable.mj_header_lastupdate.key.localized, time)
                }
            }
        }
        
        if let footer = self as? MJRefreshAutoNormalFooter {
            footer.setTitle(RLocalizable.mj_footer_refresh.key.localized, for: .idle)
            footer.setTitle(RLocalizable.mj_footer_loading.key.localized, for: .refreshing)
            footer.setTitle(RLocalizable.mj_footer_nodata.key.localized, for: .noMoreData)
        }
    }
}

public class LTRefreshHeader: MJRefreshNormalHeader {

    public var headerRefresh = PublishRelay<Void>()
    convenience init() {
        self.init(frame: CGRect.zero)
        self.setupLocalizedStrings()
        self.refreshingBlock = {[weak self] in
            self?.headerRefresh.accept(())
        }
    }
}

public class LTRefreshFooter: MJRefreshAutoNormalFooter {
    
    public var footerRefresh = PublishRelay<Void>()
    convenience init() {
        self.init(frame: CGRect.zero)
        self.setupLocalizedStrings()
        self.refreshingBlock = {[weak self] in
            self?.footerRefresh.accept(())
        }
    }
}

// MARK: -
/// 下拉刷新
protocol LTPullRefreshDataProvider: AnyObject {
    associatedtype Element
    
    var mjHeaderView: LTRefreshHeader { get }
    var dataList: [Element] { get set }
    
    func pullRefresh()
}

extension LTPullRefreshDataProvider {
    func pullRefresh() {}
}

/// 上拉加载更多
protocol LTLoadMoreDataProvider: AnyObject {
    associatedtype Element
    
    var mjFooterView: LTRefreshFooter { get }
//    var pageNum: Int { get set }
//    var pageSize: Int { get }
    var dataList: [Element] { get set }
    
    func loadMoreData()
}

extension LTLoadMoreDataProvider {
    func loadMoreData() {}
}
