import UIKit

@available(iOS 17.0, *)
@MainActor
final class TraitThemeEnvironment: ThemeEnvironment {
    func install(on window: UIWindow) { window.traitOverrides.appColorTheme = .default }
    func setColorTheme(_ colorTheme: ColorTheme, in viewController: UIViewController) {
        viewController.traitOverrides.appColorTheme = colorTheme
    }
    func colorTheme(for viewController: UIViewController) -> ColorTheme {
        viewController.traitCollection.appColorTheme
    }
    func theme(for viewController: UIViewController) -> AppTheme {
        let appearance: Appearance = viewController.traitCollection.userInterfaceStyle == .dark ? .dark : .light
        return AppThemeResolver.resolve(appearance: appearance, colorTheme: viewController.traitCollection.appColorTheme)
    }
}
