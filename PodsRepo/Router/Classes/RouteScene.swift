//
//  AppScene.swift
//  HBSwiftKit_Example
//
//  Created by hubin.h on 2024/12/3.
//  Copyright © 2025 Hubin_Huang. All rights reserved.

import Foundation
import AVKit
import AppStart

// MARK: - global var and methods
public enum RouteScene: SceneProvider {
 
    case testList

    // MARK: -
    public var getSegue: UIViewController? {
        switch self {
        case .testList:
            return TestListController(viewModel: ViewModel())
        }
    }
}
