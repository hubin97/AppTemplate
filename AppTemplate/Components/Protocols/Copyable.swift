//
//  Copyable.swift
//  Momcozy
//
//  Created by hubin.h on 2024/9/19.
//  Copyright © 2025 Hubin_Huang. All rights reserved.

import Foundation

/// 拷贝协议
/// 使用 NSCopying 和 NSMutableCopying必须作用于一个NSObject对象
/// 而如果是结构体或者枚举的话, 则无需使用拷贝协议
///
protocol Copyable {
    associatedtype T
    func copy() -> T
}
