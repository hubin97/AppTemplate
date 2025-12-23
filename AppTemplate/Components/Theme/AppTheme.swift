//
//  AppTheme.swift
//  AppTemplate
//
//  Created by hubin.h on 2025/12/11.
//  Copyright © 2025 hubin.h. All rights reserved.

import Foundation

// MARK: - Global Variables & Functions (if necessary)

// MARK: - Theme Type
enum ThemeType: String, Codable {
    case light
    case dark
}

// MARK: - Main Class
protocol AppTheme {
    var type: ThemeType { get }
    var statusBarStyle: UIStatusBarStyle { get }
    var backgroundColor: UIColor { get }
    var tableViewColor: UIColor { get }
    var textColor: UIColor { get }
    var tintColor: UIColor { get }
}

struct LightTheme: AppTheme {
    let type: ThemeType = .light
    let statusBarStyle = UIStatusBarStyle.default
    let backgroundColor = UIColor.white
    var tableViewColor = SFColor.FlatUI.clouds
    let textColor = UIColor.black
    let tintColor: UIColor = .green
}

struct DarkTheme: AppTheme {
    let type: ThemeType = .dark
    let statusBarStyle = UIStatusBarStyle.lightContent
    let backgroundColor = UIColor.black
    var tableViewColor = UIColor.black
    let textColor = UIColor.white
    let tintColor: UIColor = .darkGray
}
