//
//  MineViewController.swift
//  AppTemplate
//
//  Created by hubin.h on 2025/12/10.
//  Copyright © 2025 hubin.h. All rights reserved.

import Foundation
import Kingfisher
// MARK: - Global Variables & Functions (if necessary)

// MARK: - Main Class
class MineViewController: DefaultViewController, ViewModelProvider {
    typealias ViewModelType = MineViewModel

    lazy var tableView: TableView = {
        let listView = TableView(frame: CGRect.zero, style: .plain)
        listView.registerCell(SettingCell.self)
        listView.tableFooterView = UIView(frame: CGRect.zero)
        listView.dataSource = self
        listView.delegate = self
        listView.rowHeight = 50
        listView.mj_header = RefreshHeader(refreshingBlock: {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                listView.mj_header?.endRefreshing()
            }
        })
        return listView
    }()

    override func setupLayout() {
        super.setupLayout()
        view.addSubview(tableView)
        naviBar.title = "Profile"
        naviBar.leftView?.isHidden = true
        
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(naviBar.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    override func bindViewModel() {
        super.bindViewModel()

        let refresh = Observable.of(
            rx.viewWillAppear.mapToVoid(),
            vm.languageDidChange.asObservable()
        ).merge()
        refresh.bind(to: vm.refresh).disposed(by: rx.disposeBag)
    }

    override var themeableTableViews: [UITableView] { [tableView] }
}

// MARK: - Private Methods
extension MineViewController {
}

// MARK: - Callbacks
extension MineViewController {
}

// MARK: - Utilities & Helpers
extension MineViewController {
}

// MARK: - Delegate & Data Source
extension MineViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vm.items.value.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = vm.items.value[indexPath.row]
        let cell = tableView.getReusableCell(indexPath, SettingCell.self)
        cell.bind(to: item)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = vm.items.value[indexPath.row]
        switch item.itemType {
        case .displayMode:
            presentDisplayModePicker()
        case .themePalette:
            presentThemePalettePicker()
        case .language:
            presentLanguagePicker()
        default:
            break
        }
    }
}

private extension MineViewController {
    func presentDisplayModePicker() {
        let alert = UIAlertController(title: "显示模式", message: nil, preferredStyle: .actionSheet)
        ThemeMode.allCases.forEach { mode in
            let title = mode == vm.displayMode.value ? "✓ \(mode.displayName)" : mode.displayName
            alert.addAction(UIAlertAction(title: title, style: .default) { [weak self] _ in
                Task { @MainActor in
                    self?.vm.selectDisplayMode(mode)
                }
            })
        }
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        present(alert, animated: true)
    }

    func presentThemePalettePicker() {
        let alert = UIAlertController(title: "主题设置", message: nil, preferredStyle: .actionSheet)
        ThemePalette.allCases.forEach { palette in
            let color = palette.accentColor(for: Theme.current.appearance)
            let title = palette == vm.themePalette.value ? "✓ \(palette.displayName)" : palette.displayName
            let action = UIAlertAction(title: title, style: .default) { [weak self] _ in
                Task { @MainActor in
                    self?.vm.selectThemePalette(palette)
                }
            }
            action.setValue(color, forKey: "titleTextColor")
            alert.addAction(action)
        }
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        present(alert, animated: true)
    }

    func presentLanguagePicker() {
        let alert = UIAlertController(title: "语言设置", message: nil, preferredStyle: .actionSheet)
        LocalizedUtils.supportedLanguages.forEach { language in
            let title = language == vm.language.value ? "✓ \(language.rawValue)" : language.rawValue
            alert.addAction(UIAlertAction(title: title, style: .default) { [weak self] _ in
                Task { @MainActor in
                    self?.vm.selectLanguage(language)
                }
            })
        }
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        present(alert, animated: true)
    }
}
