# Theme Architecture

UIKit theme architecture for iOS 15.1+.

- Appearance: system/light/dark
- AppTheme: resolved business theme
- ColorTheme: optional business dimension
- Dark-mode-only apps can use only `ColorTheme.default`
- Business owns AppColors and AppThemeResolver
- ThemeApplicable exposes `themeDidChange(_:)`
- iOS 17 uses custom traits for hierarchical ColorTheme propagation
- iOS 15/16 keep a removable fallback
