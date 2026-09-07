# Architecture Notes

## Dark-mode-only

`ColorTheme` is an optional business dimension. A project that only needs dark mode uses `ColorTheme.default` and does not need multiple color themes.

The effective flow is:

Appearance -> AppTheme -> AppColors

The capability remains available for projects that later need `.blue`, `.green`, etc.

## Responsibilities

Infrastructure: Appearance, AppearanceMode, ThemeApplicable, theme environment, iOS 17 trait integration, iOS 15/16 fallback.

Business: ColorTheme meaning/cases, AppColors, AppThemeResolver, actual UI styling.

## UIViewController

Use the existing global `ViewController` as the lifecycle bridge. Do not create ThemeViewController or AppearanceViewController.

## UIView

Do not add a Theme-specific UIView base class solely for this. Prefer dynamic UIColor for pure color changes; use an existing base or local trait registration for special behavior.

## iOS 17 migration

When the deployment target reaches iOS 17, remove `Theme/Legacy/` and simplify the factory to return `TraitThemeEnvironment`.
