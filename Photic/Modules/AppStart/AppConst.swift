//
//  AppConst.swift
//  Photic
//
//  Created by lanht on 2022/8/28.
//

import Foundation
import UIKit

let ScreenSize = UIScreen.main.bounds.size

let ScreenWidth = ScreenSize.width

let ScreenHeight = ScreenSize.height

let safeTop = UIApplication.shared.keyWindow?.safeAreaInsets.top ?? 0
let safeBottom = UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0

// 导航栏高度（不包含状态栏）
let NavBarHeight = 44.0
// 状态栏高度
let StatusBarH = UIApplication.shared.statusBarFrame.height
// 导航栏高度（包含状态栏）
let NavigationH: CGFloat = NavBarHeight + StatusBarH

// tabbar高度
let TabBarHeight: CGFloat = ((UIApplication.shared.statusBarFrame.height > 20) ? 83 : 49)
