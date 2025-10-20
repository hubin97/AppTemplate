//
//  Copyable.swift
//  Momcozy
//
//  Created by hubin.h on 2024/9/19.
//  Copyright © 2025 Hubin_Huang. All rights reserved.

import Foundation

/// 拷贝协议
/// Swift 的理念是让数据不可变（immutable）优先，优先值类型, 而不是引用类型
/// 所以只有`自定义引用类型才有可能使用此协议, 其它情景几乎使用不到`
protocol Copyable {
    func copy() -> Self
}
