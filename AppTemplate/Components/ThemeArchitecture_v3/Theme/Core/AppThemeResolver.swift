import UIKit

/// Business-owned theme assembly. Extend ColorTheme and this resolver when needed.
public enum AppThemeResolver {
    public static func resolve(appearance: Appearance, colorTheme: ColorTheme = .default) -> AppTheme {
        let dark = appearance == .dark
        let colors = AppColors(
            pageBackground: dark ? .black : .white,
            tableBackground: dark ? .black : .white,
            primaryText: dark ? .white : .black,
            secondaryText: dark ? .lightGray : .darkGray,
            brand: .systemBlue,
            separator: dark ? .darkGray : .lightGray
        )
        return AppTheme(appearance: appearance, colorTheme: colorTheme, colors: colors)
    }
}
