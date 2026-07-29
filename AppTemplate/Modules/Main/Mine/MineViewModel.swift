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
    let languageDidChange = PublishSubject<Void>()

    let displayMode = BehaviorRelay<ThemeMode>(value: Theme.current.mode)
    let themePalette = BehaviorRelay<ThemePalette>(value: Theme.current.palette)
    let language = BehaviorRelay<LocalizedUtils.LanguageCode>(value: LocalizedUtils.currentLanguageCode())

    // Outputs
    let items = BehaviorRelay<[SettingCellViewModel]>(value: [])
    let cacheSizeRelay = BehaviorRelay<Int>(value: 0)

    required init() {
        super.init()
        
        displayMode
            .skip(1)
            .subscribe(onNext: { mode in
                if Theme.current.mode != mode {
                    Theme.set(mode: mode)
                }
            })
            .disposed(by: rx.disposeBag)

        themePalette
            .skip(1)
            .subscribe(onNext: { palette in
                if Theme.current.palette != palette {
                    Theme.set(palette: palette)
                }
            })
            .disposed(by: rx.disposeBag)

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
    }

    func selectThemePalette(_ palette: ThemePalette) {
        themePalette.accept(palette)
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
