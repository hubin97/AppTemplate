import UIKit

public struct AppTheme: Equatable {
    public let appearance: Appearance
    public let colorTheme: ColorTheme
    public let colors: AppColors
    public init(appearance: Appearance, colorTheme: ColorTheme, colors: AppColors) {
        self.appearance = appearance; self.colorTheme = colorTheme; self.colors = colors
    }
}

/// Business-owned; fields should be shaped by the design system/business.
public struct AppColors: Equatable {
    public let pageBackground: UIColor
    public let tableBackground: UIColor
    public let primaryText: UIColor
    public let secondaryText: UIColor
    public let brand: UIColor
    public let separator: UIColor
    public init(pageBackground: UIColor, tableBackground: UIColor, primaryText: UIColor,
                secondaryText: UIColor, brand: UIColor, separator: UIColor) {
        self.pageBackground = pageBackground; self.tableBackground = tableBackground
        self.primaryText = primaryText; self.secondaryText = secondaryText
        self.brand = brand; self.separator = separator
    }
}
