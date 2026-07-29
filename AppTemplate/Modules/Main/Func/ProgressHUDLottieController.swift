//
//  ProgressHUDLottieController.swift
//  AppTemplate
//
//  ProgressHUD 示例（同步自 https://github.com/relatedcode/ProgressHUD README UIKit API）
//  + Lottie 业务集成示例

import UIKit
import AppStart

// MARK: - Main Class
class ProgressHUDLottieController: DefaultViewController {

    enum Section: Int, CaseIterable {
        case banner
        case animate
        case liveIcon
        case progress
        case symbol
        case staticResult
        case lottie
        case control

        var title: String {
            switch self {
            case .banner: return "Banner"
            case .animate: return "Animate"
            case .liveIcon: return "Live Icon"
            case .progress: return "Progress"
            case .symbol: return "Symbol"
            case .staticResult: return "Static Image"
            case .lottie: return "Lottie（业务扩展）"
            case .control: return "Control"
            }
        }
    }

    enum DemoItem: CaseIterable {
        // Banner
        case banner
        case bannerDelay
        case bannerHide
        // Animate
        case animate
        case animateNoInteraction
        case animateBallBounce
        case animateSymbol
        // Live Icon
        case succeed
        case succeedDelay
        case failed
        case failedText
        case added
        // Progress
        case progress
        case progressText
        // Symbol
        case symbol
        case symbolText
        // Static
        case success
        case error
        // Lottie
        case lottieSimple
        case lottieDefault
        case lottieWithMessage
        case lottieNoMessage
        case lottieLargeLottie
        // Control
        case dismiss
        case remove

        var title: String {
            switch self {
            case .banner: return #"banner("Banner title", "Banner message")"#
            case .bannerDelay: return #"banner(..., delay: 2.0)"#
            case .bannerHide: return "bannerHide()"
            case .animate: return #"animate("Some text...")"#
            case .animateNoInteraction: return #"animate("Some text...", interaction: false)"#
            case .animateBallBounce: return #"animate("Please wait...", .ballVerticalBounce)"#
            case .animateSymbol: return #"animate("Loading...", symbol: "star.fill")"#
            case .succeed: return "succeed()"
            case .succeedDelay: return #"succeed("Some text...", delay: 1.5)"#
            case .failed: return "failed()"
            case .failedText: return #"failed("Some text...")"#
            case .added: return #"added("Item added")"#
            case .progress: return "progress(0.15)"
            case .progressText: return #"progress("Loading...", 0.42)"#
            case .symbol: return #"symbol(name: "box.truck")"#
            case .symbolText: return #"symbol("Some text...", name: "sun.max")"#
            case .success: return #"success("Success message")"#
            case .error: return #"error("Error message")"#
            case .lottieSimple: return #"showSimpleLottieLoading(named: "loading")"#
            case .lottieDefault: return #"showLottieLoading(message: "加载中...")"#
            case .lottieWithMessage: return #"showLottieLoading(message: "请稍候")"#
            case .lottieNoMessage: return #"showLottieLoading(message: nil)"#
            case .lottieLargeLottie: return #"showLottieLoading(lottieSize: 72×72)"#
            case .dismiss: return "dismiss()"
            case .remove: return "remove()"
            }
        }

        var section: Section {
            switch self {
            case .banner, .bannerDelay, .bannerHide: return .banner
            case .animate, .animateNoInteraction, .animateBallBounce, .animateSymbol: return .animate
            case .succeed, .succeedDelay, .failed, .failedText, .added: return .liveIcon
            case .progress, .progressText: return .progress
            case .symbol, .symbolText: return .symbol
            case .success, .error: return .staticResult
            case .lottieSimple, .lottieDefault, .lottieWithMessage, .lottieNoMessage, .lottieLargeLottie: return .lottie
            case .dismiss, .remove: return .control
            }
        }

        func run() {
            switch self {
            case .banner:
                ProgressHUD.banner("Banner title", "Banner message to display.")
            case .bannerDelay:
                ProgressHUD.banner("Banner title", "Message to display.", delay: 2.0)
            case .bannerHide:
                ProgressHUD.bannerHide()
            case .animate:
                ProgressHUD.animate("Some text...")
            case .animateNoInteraction:
                ProgressHUD.animate("Some text...", interaction: false)
            case .animateBallBounce:
                ProgressHUD.animate("Please wait...", .ballVerticalBounce)
            case .animateSymbol:
                ProgressHUD.animate("Loading...", symbol: "star.fill")
            case .succeed:
                ProgressHUD.succeed()
            case .succeedDelay:
                ProgressHUD.succeed("Some text...", delay: 1.5)
            case .failed:
                ProgressHUD.failed()
            case .failedText:
                ProgressHUD.failed("Some text...")
            case .added:
                ProgressHUD.added("Item added")
            case .progress:
                ProgressHUD.progress(0.15)
            case .progressText:
                ProgressHUD.progress("Loading...", 0.42)
            case .symbol:
                ProgressHUD.symbol(name: "box.truck")
            case .symbolText:
                ProgressHUD.symbol("Some text...", name: "sun.max")
            case .success:
                ProgressHUD.success("Success message")
            case .error:
                ProgressHUD.error("Error message")
            case .lottieSimple:
                ProgressHUD.showSimpleLottieLoading(named: "loading")
            case .lottieDefault:
                ProgressHUD.showLottieLoading(named: "loading", message: "加载中...")
            case .lottieWithMessage:
                ProgressHUD.showLottieLoading(named: "loading", message: "请稍候")
            case .lottieNoMessage:
                ProgressHUD.showLottieLoading(named: "loading", message: nil)
            case .lottieLargeLottie:
                ProgressHUD.showLottieLoading(
                    named: "loading",
                    message: "加载中...",
                    lottieSize: CGSize(width: 72, height: 72)
                )
            case .dismiss:
                ProgressHUD.dismiss()
            case .remove:
                ProgressHUD.remove()
            }
        }
    }

    private let sections: [Section] = Section.allCases
    private lazy var itemsBySection: [[DemoItem]] = {
        Section.allCases.map { section in
            DemoItem.allCases.filter { $0.section == section }
        }
    }()

    private lazy var tableView: UITableView = {
        let view = UITableView(frame: .zero, style: .insetGrouped)
        view.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        view.dataSource = self
        view.delegate = self
        view.rowHeight = 48
        return view
    }()

    override func setupLayout() {
        super.setupLayout()
        naviBar.title = "ProgressHUD"
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(naviBar.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }

    override func bindViewModel() {
        super.bindViewModel()
        setupProgressHUD()
    }

    override var themeableTableViews: [UITableView] { [tableView] }

    override func themeDidChange(_ theme: AppTheme) {
        super.themeDidChange(theme)
        ProgressHUD.colorAnimation = theme.colors.tint
        ProgressHUD.colorStatus = theme.colors.tint
        ProgressHUD.colorProgress = theme.colors.tint
    }
    
    func setupProgressHUD() {
        let theme = Theme.current
        ProgressHUD.colorAnimation = theme.colors.tint
        ProgressHUD.colorStatus = theme.colors.tint
        ProgressHUD.fontStatus = Fonts.figma(.w500)(16)
        ProgressHUD.colorProgress = theme.colors.tint
        ProgressHUD.animationType = .circleStrokeSpin
        //ProgressHUD.imageSuccess = R.image.icon_hud_success()!
        //ProgressHUD.imageError = R.image.icon_hud_error()!

        if #available(iOS 26.0, *) {
            ProgressHUD.colorHUD = UIColor.white
        }
    }
}

// MARK: - DemoItem
extension ProgressHUDLottieController.DemoItem {
    static var allCases: [ProgressHUDLottieController.DemoItem] {
        [
            .banner, .bannerDelay, .bannerHide,
            .animate, .animateNoInteraction, .animateBallBounce, .animateSymbol,
            .succeed, .succeedDelay, .failed, .failedText, .added,
            .progress, .progressText,
            .symbol, .symbolText,
            .success, .error,
            .lottieSimple, .lottieDefault, .lottieWithMessage, .lottieNoMessage, .lottieLargeLottie,
            .dismiss, .remove
        ]
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate
extension ProgressHUDLottieController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        itemsBySection[section].count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        sections[section].title
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let item = itemsBySection[indexPath.section][indexPath.row]
        var config = cell.defaultContentConfiguration()
        config.text = item.title
        config.textProperties.font = .monospacedSystemFont(ofSize: 13, weight: .regular)
        config.textProperties.numberOfLines = 2
        cell.contentConfiguration = config
        cell.selectionStyle = .default
        cell.backgroundColor = UIColor(hexStr: "#F9F7F5")
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        itemsBySection[indexPath.section][indexPath.row].run()
    }
}
