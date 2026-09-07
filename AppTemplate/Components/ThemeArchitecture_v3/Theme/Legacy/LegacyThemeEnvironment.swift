import UIKit
import ObjectiveC

/// Minimal iOS 15/16 fallback for the custom ColorTheme context.
@MainActor
final class LegacyThemeEnvironment: ThemeEnvironment {
    private static var colorThemeKey: UInt8 = 0
    func install(on window: UIWindow) { setAssociatedColorTheme(.default, on: window.rootViewController) }
    func setColorTheme(_ colorTheme: ColorTheme, in viewController: UIViewController) {
        setAssociatedColorTheme(colorTheme, on: viewController)
    }
    func colorTheme(for viewController: UIViewController) -> ColorTheme {
        var current: UIViewController? = viewController
        while let vc = current {
            if let value = associatedColorTheme(on: vc) { return value }
            current = vc.presentingViewController ?? vc.parent
        }
        return .default
    }
    func theme(for viewController: UIViewController) -> AppTheme {
        let appearance: Appearance = viewController.traitCollection.userInterfaceStyle == .dark ? .dark : .light
        return AppThemeResolver.resolve(appearance: appearance, colorTheme: colorTheme(for: viewController))
    }
    private func setAssociatedColorTheme(_ value: ColorTheme, on vc: UIViewController?) {
        guard let vc else { return }
        objc_setAssociatedObject(vc, &Self.colorThemeKey, value.rawValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    private func associatedColorTheme(on vc: UIViewController) -> ColorTheme? {
        guard let raw = objc_getAssociatedObject(vc, &Self.colorThemeKey) as? Int else { return nil }
        return ColorTheme(rawValue: raw)
    }
}
