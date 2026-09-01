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
@MainActor
class MineViewModel: ViewModel {
    
    // Rx 回调不在 MainActor 上；Subject / Relay 本身线程安全，允许非隔离读写。
    nonisolated(unsafe) let refresh = PublishSubject<Void>()
    nonisolated(unsafe) let removeCache = PublishSubject<Void>()
    nonisolated(unsafe) let languageDidChange = PublishSubject<Void>()

    nonisolated(unsafe) let displayMode: BehaviorRelay<ThemeMode>
    nonisolated(unsafe) let themePalette: BehaviorRelay<ThemePalette>
    nonisolated(unsafe) let language: BehaviorRelay<LocalizedUtils.LanguageCode>

    nonisolated(unsafe) let items = BehaviorRelay<[SettingCellViewModel]>(value: [])
    nonisolated(unsafe) let cacheSizeRelay = BehaviorRelay<Int>(value: 0)

    required init() {
        // `NSObject.init` 是非隔离；Mine 页只在主线程建 VM。
        let initialMode = MainActor.assumeIsolated { Theme.current.mode }
        let initialPalette = MainActor.assumeIsolated { Theme.current.palette }
        displayMode = BehaviorRelay(value: initialMode)
        themePalette = BehaviorRelay(value: initialPalette)
        language = BehaviorRelay(value: LocalizedUtils.currentLanguageCode())
        super.init()
        
        language
            .skip(1)
            .subscribe(onNext: { [weak self] code in
                LocalizedUtils.updateLocalized(code) {
                    self?.languageDidChange.onNext(())
                }
            })
            .disposed(by: rx.disposeBag)

        let cacheRemoved = removeCache
            .flatMapLatest { ImageCache.default.rx.clearCache() }
        let cacheSize = Observable
            .merge(refresh, cacheRemoved)
            .flatMapLatest { ImageCache.default.rx.retrieveCacheSize() }

        let displayModeViewModel = SettingCellViewModel(itemType: .displayMode(displayMode.value))
        displayMode
            .map(\.displayName)
            .bind(to: displayModeViewModel.detail)
            .disposed(by: rx.disposeBag)
        
        let themePaletteViewModel = SettingCellViewModel(itemType: .themePalette(themePalette.value))
        themePalette
            .map(\.displayName)
            .bind(to: themePaletteViewModel.detail)
            .disposed(by: rx.disposeBag)

        let languageViewModel = SettingCellViewModel(itemType: .language(language.value))
        language
            .map(\.rawValue)
            .bind(to: languageViewModel.detail)
            .disposed(by: rx.disposeBag)
        
        let clearCacheViewModel = SettingCellViewModel(itemType: .clearCache)
        cacheSize
            .map { "\($0 / 1024 / 1024) MB" }
            .bind(to: clearCacheViewModel.detail)
            .disposed(by: rx.disposeBag)
        
        let aboutViewModel = SettingCellViewModel(itemType: .aboutUs)

        self.items.accept([
            displayModeViewModel,
            themePaletteViewModel,
            languageViewModel,
            clearCacheViewModel,
            aboutViewModel
        ])
    }

    func selectDisplayMode(_ mode: ThemeMode) {
        displayMode.accept(mode)
        Theme.set(mode: mode)
    }

    func selectThemePalette(_ palette: ThemePalette) {
        themePalette.accept(palette)
        Theme.set(palette: palette)
    }

    func selectLanguage(_ language: LocalizedUtils.LanguageCode) {
        self.language.accept(language)
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
