import UIKit

@MainActor
protocol ThemeEnvironment {
    func install(on window: UIWindow)
    func setColorTheme(_ colorTheme: ColorTheme, in viewController: UIViewController)
    func colorTheme(for viewController: UIViewController) -> ColorTheme
    func theme(for viewController: UIViewController) -> AppTheme
}
