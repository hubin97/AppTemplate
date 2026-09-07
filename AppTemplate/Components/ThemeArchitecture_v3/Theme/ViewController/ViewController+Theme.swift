import UIKit

extension ViewController {
    /// Called by the existing global ViewController; pages do not register themselves.
    @MainActor
    func setupThemeObservation() {
        if #available(iOS 17.0, *) {
            registerForTraitChanges([UITraitUserInterfaceStyle.self, AppColorThemeTrait.self]) { [weak self] _, _ in
                self?.notifyThemeDidChange()
            }
        }
        notifyThemeDidChange()
    }

    @MainActor
    func notifyThemeDidChange() {
        guard let target = self as? ThemeApplicable else { return }
        target.themeDidChange(ThemeEnvironmentFactory.make().theme(for: self))
    }
}
