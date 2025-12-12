//
//  MineViewModel.swift
//  AppTemplate
//
//  Created by hubin.h on 2025/12/10.
//  Copyright © 2025 hubin.h. All rights reserved.

import Foundation
import Kingfisher

// MARK: - Global Variables & Functions (if necessary)

// MARK: - Main Class
class MineViewModel: ViewModel {
    
    // Inputs（简单暴露，不用 struct）
    let refresh = PublishSubject<Void>()
    let removeCache = PublishSubject<Void>()

    let nightModeEnabled = BehaviorRelay<Bool>(value: ThemeService.shared.isDark)
    let themeName = BehaviorRelay<String>(value: "blue")
    let language = BehaviorRelay<String>(value: Locale.current.languageCode ?? "中文")

    // Outputs
    let items = BehaviorRelay<[SettingCellViewModel]>(value: [])
    let cacheSizeRelay = BehaviorRelay<Int>(value: 0)

    required init() {
        super.init()
        
        nightModeEnabled
            .skip(1)
            .subscribe(onNext: { isEnabled in
                if ThemeService.shared.isDark != isEnabled {
                    ThemeService.shared.toggle()
                }
            })
            .disposed(by: rx.disposeBag)

        let cacheRemoved = removeCache
            .flatMapLatest { ImageCache.default.rx.clearCache() }
        let cacheSize = Observable
            .merge(refresh, cacheRemoved)
            .flatMapLatest { ImageCache.default.rx.retrieveCacheSize() }

        let nightModeViewModel = SettingCellViewModel(itemType: .nightMode(nightModeEnabled.value), hideNext: true)
        nightModeViewModel.switchChanged
            .bind(to: nightModeEnabled)
            .disposed(by: rx.disposeBag)
        
        let themeModeViewModel = SettingCellViewModel(itemType: .themeMode(themeName.value))
        let languageViewModel = SettingCellViewModel(itemType: .language(language.value))
        
        let clearCacheViewModel = SettingCellViewModel(itemType: .clearCache)
        cacheSize
            .map { "\($0 / 1024 / 1024) MB" }
            .bind(to: clearCacheViewModel.detail)
            .disposed(by: rx.disposeBag)
        
        let aboutViewModel = SettingCellViewModel(itemType: .aboutUs)

        self.items.accept([nightModeViewModel, themeModeViewModel, languageViewModel, clearCacheViewModel, aboutViewModel])
    }
}

// MARK: - Private Methods
extension MineViewModel {
}

// MARK: - Callbacks
extension MineViewModel {
}

// MARK: - Utilities & Helpers
extension MineViewModel {
}

// MARK: - Delegate & Data Source
extension MineViewModel {
}
