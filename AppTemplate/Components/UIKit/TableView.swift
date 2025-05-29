//
//  TableView.swift
//  Momcozy
//
//  Created by hubin.h on 2024/8/13.
//  Copyright © 2025 Hubin_Huang. All rights reserved.

import Foundation
import DZNEmptyDataSet
import RxRelay
import MJRefresh

/// 1. 扩展下拉刷新, 上拉加载方法
/// 2. 添加通用空白占位控件, 以及点击事件
///
open class TableView: UITableView {
    
    var mjHeaderView = LTRefreshHeader()
    var mjFooterView = LTRefreshFooter()

    /// 点击空页面视图
    public let didTapEmptyView: PublishRelay = PublishRelay<Void>()
    /// `EmptyView`垂直偏移量
    public var verticalOffset: CGFloat = 0
    /// `EmptyView`图片
    public var imageForEmptyDataSet: UIImage?
    /// `EmptyView`标题
    public var titleForEmptyDataSet: String?
    /// `EmptyView`是否显示条件
    public var emptyDataSetShouldDisplay: Bool = true
    
    /// `EmptyView`标题默认属性
    public var atattributesForTitle = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15), NSAttributedString.Key.foregroundColor: UIColor(hexStr: "#999999")]

    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        self.emptyDataSetSource = self
        self.emptyDataSetDelegate = self
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 设置段头下拉刷新
    func setHeaderRefresh(_ block: @escaping (() -> Void)) {
        self.mj_header = self.mjHeaderView
        self.mj_header?.refreshingBlock = block
    }
    
    /// 设置段头上拉加载
    func setFooterRefresh(_ block: @escaping (() -> Void)) {
        self.mj_footer = self.mjFooterView
        self.mj_footer?.refreshingBlock = block
    }
}

// MARK: - other classes
extension TableView: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    
    public func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return self.imageForEmptyDataSet ?? R.image.icon_null_data()
    }
    public func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        return NSAttributedString(string: self.titleForEmptyDataSet ?? RLocalizable.string_not_record_yet_tips.key.localized, attributes: atattributesForTitle)
    }
    public func verticalOffset(forEmptyDataSet scrollView: UIScrollView!) -> CGFloat {
        return self.verticalOffset
    }
    public func emptyDataSet(_ scrollView: UIScrollView!, didTap view: UIView!) {
        self.didTapEmptyView.accept(())
    }
    public func emptyDataSetShouldDisplay(_ scrollView: UIScrollView!) -> Bool {
        return emptyDataSetShouldDisplay
    }
}
