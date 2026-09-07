import UIKit

@available(iOS 17.0, *)
struct AppColorThemeTrait: UITraitDefinition {
    static let defaultValue: ColorTheme = .default
    static let name = "App Color Theme"
}

@available(iOS 17.0, *)
extension UITraitCollection {
    var appColorTheme: ColorTheme { self[AppColorThemeTrait.self] }
}

@available(iOS 17.0, *)
extension UIMutableTraits {
    var appColorTheme: ColorTheme {
        get { self[AppColorThemeTrait.self] }
        set { self[AppColorThemeTrait.self] = newValue }
    }
}
