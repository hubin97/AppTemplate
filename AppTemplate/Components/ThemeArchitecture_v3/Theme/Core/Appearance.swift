import UIKit

public enum Appearance: Equatable { case light, dark }

public enum AppearanceMode: Equatable {
    case system, light, dark
    public func apply(to window: UIWindow) {
        switch self {
        case .system: window.overrideUserInterfaceStyle = .unspecified
        case .light: window.overrideUserInterfaceStyle = .light
        case .dark: window.overrideUserInterfaceStyle = .dark
        }
    }
}
