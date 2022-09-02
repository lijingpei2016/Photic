//
//  EditViewConfig.swift
//  Photic
//
//  Created by Lanht on 2022/9/2.
//

import Foundation
import UIKit

let editViewHeaderH = safeTop + 44.0
let editViewFooterH = safeBottom + 44.0

let previewH = (ScreenHeight - CGFloat(editViewHeaderH) - CGFloat(editViewFooterH)) / 2.0

let controlViewH = previewH
let controlViewContentInset = UIEdgeInsets(top: 0, left: ScreenWidth / 2.0, bottom: 0, right: ScreenWidth / 2.0)

let timeLineViewH = 40.0

let segmentViewTop = timeLineViewH + 20.0
let segmentViewH = 40.0

let centerLineTop = segmentViewTop - 30
let centerLineH = 90
