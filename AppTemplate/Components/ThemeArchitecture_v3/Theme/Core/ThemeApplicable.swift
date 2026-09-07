@MainActor
public protocol ThemeApplicable: AnyObject {
    func themeDidChange(_ theme: AppTheme)
}
