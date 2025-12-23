//
//  Themeable.swift
//  AppTemplate
//
//  Created by hubin.h on 2025/12/11.
//  Copyright © 2025 hubin.h. All rights reserved.

import Foundation
import RxSwift
import RxCocoa

// MARK: - Global Variables & Functions (if necessary)

// MARK: - Main Class
protocol Themeable: NSObject {
    // Swift 协议里的 Self 只能用于 final 类 / struct / enum，或者只在返回值/泛型约束里出现;
    // UI 层组件 + 逃逸闭包 + 可继承类 → 不要在协议 requirement 中用 Self
    //func withThemeUpdates(_ handler: @escaping (Self, AppTheme) -> Void)
}

extension Themeable {
    
    /// 使用主题，并在主题变化时自动更新。
    /// 注意：会立即应用当前主题，然后订阅后续的主题变化
    /// 自动处理 weak self，无需手动添加 [weak self] 和 guard let self
    func withThemeUpdates(_ handler: @escaping (Self, AppTheme) -> Void) {
        // 立即应用当前主题
        handler(self, ThemeService.shared.current)
        
        // 订阅主题变化，自动处理 weak self
        ThemeService.shared.theme
            .skip(1) // 跳过当前值，因为已经立即应用了
            .subscribe(onNext: {[weak self] theme in
                guard let strongSelf = self else { return }
                handler(strongSelf, theme)
            }).disposed(by: rx.disposeBag)
    }
}

// MARK: - Utilities & Helpers
//@propertyWrapper
//class Themed<View: UIView> {
//    private var view: View?
//
//    /// 传入闭包，定义每次主题更新要做的事情
//    private let applyClosure: (View, AppTheme) -> Void
//
//    init(apply: @escaping (View, AppTheme) -> Void) {
//        self.applyClosure = apply
//    }
//
//    var wrappedValue: View {
//        get { view! }
//        set {
//            view = newValue
//
//            // 绑定主题
//            ThemeService.shared.theme
//                .asObservable()
//                .subscribe(onNext: { [weak self] theme in
//                    guard let view = self?.view else { return }
//                    self?.applyClosure(view, theme)
//                })
//                .disposed(by: newValue.rx.disposeBag)
//
//            // 初始应用主题
//            if let view = view {
//                applyClosure(view, ThemeService.shared.currentTheme)
//            }
//        }
//    }
//}
//
//typealias ThemedView = Themed<UIView>
//typealias ThemedLabel = Themed<UILabel>
//typealias ThemedButton = Themed<UIButton>
//
////@ThemedButton(apply: { btn, theme in
////    btn.backgroundColor = theme.buttonBackground
////    btn.setTitleColor(theme.buttonText, for: .normal)
////})
////var loginButton = UIButton()
//
