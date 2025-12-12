//
//  Themeable.swift
//  AppTemplate
//
//  Created by hubin.h on 2025/12/11.
//  Copyright © 2025 hubin.h. All rights reserved.

import Foundation

// MARK: - Global Variables & Functions (if necessary)

// MARK: - Main Class
protocol Themeable: NSObject {
    func withThemeUpdates(_ handler: @escaping (AppTheme) -> Void)
}

extension Themeable {
    
    /// 使用主题，并在主题变化时自动更新。
    func withThemeUpdates(_ handler: @escaping (AppTheme) -> Void) {
        ThemeService.shared.theme
            .subscribe(onNext: { theme in
                handler(theme)
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
