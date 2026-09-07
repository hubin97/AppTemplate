import UIKit

@MainActor
enum ThemeEnvironmentFactory {
    static func make() -> ThemeEnvironment {
        if #available(iOS 17.0, *) { return TraitThemeEnvironment() }
        return LegacyThemeEnvironment()
    }
}
